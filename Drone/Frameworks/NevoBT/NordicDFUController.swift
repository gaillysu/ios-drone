//
//  NordicDFUController.swift
//  Drone
//
//  Created by Karl-John Chow on 17/7/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import UIKit
import CoreBluetooth
import iOSDFULibrary

class NordicDFUController: NSObject{
    let legacyDfuServiceUUID  = CBUUID(string: "00001530-1212-EFDE-1523-785FEABCD123")
    let secureDfuServiceUUID  = CBUUID(string: "FE59")
    
    
    var centralManager              : CBCentralManager
    var selectedPeripheral          : CBPeripheral?
    var selectedPeripheralIsSecure  : Bool?
    var discoveredPeripherals       : [CBPeripheral]
    var securePeripheralMarkers     : [Bool?]
    var scanningStarted             : Bool = false
    
    var delegate:NordicDFUDelegate
    var dfuController    : DFUServiceController?
    
    func startDiscovery() {
        if !scanningStarted && centralManager.state == .poweredOn{
            scanningStarted = true
            print("DFU: Start discovery")
            centralManager.delegate = self
            centralManager.scanForPeripherals(withServices: [
                legacyDfuServiceUUID,
                secureDfuServiceUUID])
        }
    }
    
    //MARK: - UIViewController implementation
    init(delegate:NordicDFUDelegate){
        discoveredPeripherals   = [CBPeripheral]()
        securePeripheralMarkers = [Bool?]()
        centralManager = CBCentralManager(delegate: nil, queue: nil)
        self.delegate = delegate
        super.init()
        centralManager.delegate = self
    }
    
    func performDFU(peripheral:CBPeripheral, fileUrl:URL, dfuServiceDelegate:DFUServiceDelegate?, dfuProgressDelegate:DFUProgressDelegate?, loggerDelegate:LoggerDelegate?){
        scanningStarted = false
        centralManager.stopScan()
        if let firmware = DFUFirmware(urlToZipFile: fileUrl){
            let dfuInitiator = DFUServiceInitiator(centralManager: centralManager, target: peripheral)
            dfuInitiator.delegate = dfuServiceDelegate
            dfuInitiator.progressDelegate = dfuProgressDelegate
            dfuInitiator.logger = loggerDelegate
            dfuInitiator.enableUnsafeExperimentalButtonlessServiceInSecureDfu = true
            dfuController = dfuInitiator.with(firmware: firmware).start()
        }
    }
}


extension NordicDFUController:CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("DFU: CentralManager is now powered on")
            startDiscovery()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard discoveredPeripherals.contains(peripheral) == false else { return }
        
        if advertisementData[CBAdvertisementDataServiceUUIDsKey] != nil {
            let name = peripheral.name ?? "Unknown"
            
            let secureUUIDString = secureDfuServiceUUID.uuidString
            let legacyUUIDString = legacyDfuServiceUUID.uuidString
            let advertisedUUIDstring = ((advertisementData[CBAdvertisementDataServiceUUIDsKey]!) as AnyObject).firstObject as! CBUUID
            
            if advertisedUUIDstring.uuidString == secureUUIDString {
                print("DFU: Found Secure Peripheral: \(name)")
                discoveredPeripherals.append(peripheral)
                securePeripheralMarkers.append(true)
            } else if advertisedUUIDstring.uuidString == legacyUUIDString {
                print("DFU: Found Legacy Peripheral: \(name)")
                discoveredPeripherals.append(peripheral)
                securePeripheralMarkers.append(false)
            }
            delegate.deviceFound(peripherals: discoveredPeripherals)
        }
    }
}
 
