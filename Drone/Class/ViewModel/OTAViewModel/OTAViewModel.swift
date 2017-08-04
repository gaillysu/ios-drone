//
//  OTAViewModel.swift
//  Drone
//
//  Created by Karl-John Chow on 14/7/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import iOSDFULibrary
import CoreBluetooth
import SwiftEventBus

class OTAViewModel {
    
    let statusObservable = BehaviorSubject<(status:Int,message:String)>(value: (100,"Getting newest firmware information."))
    let uploadProcessObservable = BehaviorSubject<Int>(value: 0)
    
    var dfuController:NordicDFUController?
    var versionStatusString:BehaviorSubject<String>
    var latestFirmwareUrl:URL
    var fileName:String?
    let disposeBag = DisposeBag()
    var initiationSuccess = false
    var timer:Timer?
    init(){
        guard let url = AppTheme.GET_FIRMWARE_FILES("DFUFirmware").first else{
            fatalError("Could not open Firmware file for some reason")
        }
        latestFirmwareUrl = url
        versionStatusString = BehaviorSubject<String>(value: "Current: \(DTUserDefaults.lastKnownWatchVersion), New: \(AppTheme.firmwareVersionFrom(path: url))")
        
        DTUserDefaults.lastKnownWatchVersionObservable.subscribe { event in
            if let element = event.element, let version = element{
                self.updateVersion(current: version, new: DTUserDefaults.lastKnownOtaVersion)
            }
            }.addDisposableTo(disposeBag)
        
        DTUserDefaults.lastKnownOtaVersionObservable.subscribe { event in
            if let element = event.element, let version = element {
                self.updateVersion(current: DTUserDefaults.lastKnownWatchVersion, new: version)
            }
            }.addDisposableTo(disposeBag)
    }
    
    func startDfu(){
        if let fileName = self.fileName{
            statusObservable.onNext((status: 8, message: "Downloading"))
            FirmwareNetworkManager.getOtaFile(version: DTUserDefaults.lastKnownOtaVersion, filename: fileName, process: { progress in
                self.uploadProcessObservable.onNext(Int(progress * 100))
            }, completion: { url in
                self.latestFirmwareUrl = url
                self.initiateDFU()
            }, error: { error in
                self.statusObservable.onNext((-1,"Error, Failed to download firmware"))
            })
        } else {
            initiateDFU()
        }
    }
    
    fileprivate func initiateDFU(){
        self.statusObservable.onNext((status: 9, message: "Initiating DFU"))
        AppDelegate.getAppDelegate().sendRequest(OTARequest(mode: .ble))
        _ = SwiftEventBus.onMainThread(self, name: SWIFTEVENT_OTA_PACKET_RECEIVED) { _ in
            AppDelegate.getAppDelegate().getMconnectionController()?.setOTAMode(true, Disconnect: true)
            self.dfuController = NordicDFUController(delegate: self)
            self.dfuController?.startDiscovery()
            
        }
        
    }
    
    private func updateVersion(current:Double, new:Double){
        versionStatusString.onNext("Current: \(current), New: \(new)")
    }
}

//Network functions
extension OTAViewModel{
    func firmwareInformationReceived(version:Double, description:String, date:Date, fileName:String){
        self.fileName = fileName
        self.statusObservable.onNext((100,"Ready to perform"))
    }
}

extension OTAViewModel: NordicDFUDelegate{
    func deviceFound(peripherals: [CBPeripheral]) {
        self.statusObservable.onNext((status: 10, message: "Device found!"))
        if let peripheral = peripherals.first, let dfuController = self.dfuController{
            dfuController.performDFU(peripheral: peripheral, fileUrl: latestFirmwareUrl, dfuServiceDelegate: self, dfuProgressDelegate: self, loggerDelegate: nil)
        }
    }
}

extension OTAViewModel: DFUServiceDelegate{
    func dfuError(_ error: DFUError, didOccurWithMessage message: String) {
        self.statusObservable.onNext((-1,"Error, Failed to perform OTA"))
    }
    
    func dfuStateDidChange(to state: DFUState) {
        statusObservable.onNext((state.rawValue,state.description()))
        if state == .completed{
            AppDelegate.getAppDelegate().startConnect()
            AppDelegate.getAppDelegate().watchConfig()
        }
    }
}

extension OTAViewModel:DFUProgressDelegate{
    func dfuProgressDidChange(for part: Int, outOf totalParts: Int, to progress: Int, currentSpeedBytesPerSecond: Double, avgSpeedBytesPerSecond: Double) {
        uploadProcessObservable.onNext(progress)
    }
}

