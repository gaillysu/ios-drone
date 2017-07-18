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

class OTAViewModel {
    
    let statusObservable = BehaviorSubject<DFUState>(value: .connecting)
    let uploadProcessObservable = BehaviorSubject<Int>(value: 0)
    
    var dfuController:NordicDFUController?
    var versionStatusString:String
    let latestFirmwareUrl:URL
    init(){
        guard let url = AppTheme.GET_FIRMWARE_FILES("DFUFirmware").first else{
            fatalError("Could not open Firmware file for some reason")
        }
        latestFirmwareUrl = url
        versionStatusString = "Current: \(DTUserDefaults.lastKnownWatchVersion), New: \(AppTheme.firmwareVersionFrom(path: url))"
    }
    
    func startDfu(){
        AppDelegate.getAppDelegate().sendRequest(OTARequest(mode: .ble))
        AppDelegate.getAppDelegate().getMconnectionController()?.setOTAMode(true, Disconnect: true)
        dfuController = NordicDFUController(delegate: self)
        dfuController?.startDiscovery()
    }
}

extension OTAViewModel: NordicDFUDelegate{
    func deviceFound(peripherals: [CBPeripheral]) {
        if let peripheral = peripherals.first, let dfuController = self.dfuController, let firmware = AppTheme.GET_FIRMWARE_FILES("DFUFirmware").first{
                dfuController.performDFU(peripheral: peripheral, fileUrl: firmware, dfuServiceDelegate: self, dfuProgressDelegate: self, loggerDelegate: self)
        }
    }
}

extension OTAViewModel: DFUServiceDelegate{
    func dfuError(_ error: DFUError, didOccurWithMessage message: String) {
        print("Error: \(error)")
    }
    
    func dfuStateDidChange(to state: DFUState) {
        statusObservable.onNext(state)
        if state == .completed{
            AppDelegate.getAppDelegate().startConnect()
        }
    }
}

extension OTAViewModel:DFUProgressDelegate{
    func dfuProgressDidChange(for part: Int, outOf totalParts: Int, to progress: Int, currentSpeedBytesPerSecond: Double, avgSpeedBytesPerSecond: Double) {
        uploadProcessObservable.onNext(progress)
    }
}

extension OTAViewModel:LoggerDelegate{
    func logWith(_ level: LogLevel, message: String) {
        
    }
}

