//
//  NevoBT.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation
import CoreBluetooth
// 

/*
 See NevoBT protocol
 🚧🚧🚧Backbone Class : Modify with care🚧🚧🚧
 */
class NevoBTImpl : NSObject, NevoBT, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    /**
     The scanning time is 10 sec
     */
    let SCANNING_DURATION : TimeInterval = 10.000
    
    /**
     How long before we retry to connect when the central manager is powering up
     */
    fileprivate let RETRY_DURATION : TimeInterval = 0.500
    
    /**
     Gets notified when a periphare connects/disconnects and when we receive data
     */
    fileprivate var mDelegate : NevoBTDelegate?
    
    /**
     The central manager, we have to save it
     */
    fileprivate var mManager : CBCentralManager?
    
    /**
     The connected peripheral
     only one peripheral can be connected at a time
     */
    fileprivate var mPeripheral : CBPeripheral?
    
    
    /**
     The list of peripherals we are trying to reach.
     There might be for example 10 peripherals known to the device, but one only is in range
     So we need to try to connect to all of them
     */
    fileprivate var mTryingToConnectPeripherals : [CBPeripheral] = []
    
    /**
     The GATT profile we are looking for
     */
    fileprivate var mProfile : Profile?
    
    /**
     The Stop scan timer
     */
    fileprivate var mTimer : Timer?
    
    /**
     Ble firmware version
     */
    fileprivate var mFirmwareVersion:String = ""
    
    /**
     MCU Software version
     */
    fileprivate var mSoftwareVersion:String = ""
    
    fileprivate var redRssiTimer:Timer = Timer()
    
    fileprivate var restoreKey = "DroneRestoreKey"
    
    /**
     Basic constructor, just a Delegate handsake
     */
    
    init(externalDelegate : NevoBTDelegate, acceptableDevice : Profile) {
        super.init()
        mDelegate = externalDelegate
        
        mProfile = acceptableDevice
        
        mManager = CBCentralManager(delegate:self, queue:nil, options: [CBCentralManagerOptionRestoreIdentifierKey:restoreKey])
        
        mManager?.delegate = self
    }
    
    
    // MARK: - CBCentralManagerDelegate
    /**
     Invoked whenever the central manager's state is updated.
     */
    func centralManagerDidUpdateState(_ central : CBCentralManager) {
    }
    
    /**
     Invoked when the central discovers a compatible device while scanning.
     */
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber){
        self.matchingPeripheralFound(peripheral)
    }
    
    /**
     Invoked whenever a connection is succesfully created with the peripheral.
     Discover available services on the peripheral and notifies our delegate
     */
    func centralManager(_ central: CBCentralManager, didConnect aPeripheral: CBPeripheral) {
        
        // debugPrint("***Peripheral connected : \(aPeripheral.name)***")
        
        //We save this periphral for later use
        
        if let _ = aPeripheral.services {
            setPeripheral(aPeripheral)
        }
        
        aPeripheral.discoverServices(nil)
        //We don't need to continue searching for peripherals, let's stop connecting to the others
        //We do so by forgetting them
        mTryingToConnectPeripherals = []
        
        if(redRssiTimer.isValid){
            redRssiTimer.invalidate()
        }
        redRssiTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(NevoBTImpl.redRSSI(_:)), userInfo: nil, repeats: true)
    }
    
    /**
     Invoked whenever an existing connection with the peripheral is torn down.
     Reset local variables and notifies our delegate
     */
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral aPeripheral: CBPeripheral, error : Error?) {
        
        if(error != nil) {
            // debugPrint("Error : \(error!.localizedDescription) for peripheral : \(aPeripheral.name)")
        }
        //Let's forget this device
        if let localPeripheral = mPeripheral{
            if localPeripheral.identifier == aPeripheral.identifier{
                setPeripheral(nil)
                mDelegate?.connectionStateChanged(false, fromAddress: aPeripheral.identifier)
            }
        }
        
        if(redRssiTimer.isValid){
            redRssiTimer.invalidate()
        }
    }
    
    // MARK: - CBPeripheralDelegate
    /*
     Invoked upon completion of a -[discoverServices:] request.
     Discover available characteristics on interested services
     */
    func peripheral(_ aPeripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        //Our aim is to subscribe to the callback characteristic, so we'll have to find it in the control service
        if let services:[CBService] = aPeripheral.services{
            
            for aService:CBService in services {
//                debugPrint("Service found with UUID : \(aService.uuid.uuidString)")
                
                if (aService.uuid == mProfile?.CONTROL_SERVICE) {
                    aPeripheral.discoverCharacteristics(nil,for:aService)
                }
                    //device info service
                else if (aService.uuid == CBUUID(string: "0000180a-0000-1000-8000-00805f9b34fb")) {
                    aPeripheral.discoverCharacteristics(nil,for:aService)
                }
            }
        } else {
            // debugPrint("No services found for \(aPeripheral.identifier.uuidString), connection impossible")
        }
    }
    
    /*
     Invoked upon completion of a -[discoverCharacteristics:forService:] request.
     Perform appropriate operations on interested characteristics
     */
    func peripheral(_ aPeripheral:CBPeripheral, didDiscoverCharacteristicsFor service:CBService, error :Error?) {
        
        // debugPrint("Service : \(service.uuid.uuidString)")
        
        if let characteristics:[CBCharacteristic] = service.characteristics {
            for aChar:CBCharacteristic in characteristics {
                mPeripheral?.setNotifyValue(true,for:aChar)
                if(aChar.uuid==mProfile?.CALLBACK_CHARACTERISTIC ) {
                    mPeripheral?.setNotifyValue(true,for:aChar)
                    // debugPrint("Callback char : \(aChar.uuid.uuidString)")
                    mDelegate?.connectionStateChanged(true, fromAddress: aPeripheral.identifier)
                } else if(aChar.uuid==CBUUID(string: "00002a26-0000-1000-8000-00805f9b34fb")) {
                    mPeripheral?.readValue(for: aChar)
                    // debugPrint("read firmware version char : \(aChar.uuid.uuidString)")
                } else if(aChar.uuid==CBUUID(string: "00002a28-0000-1000-8000-00805f9b34fb")) {
                    mPeripheral?.readValue(for: aChar)
                    // debugPrint("read software version char : \(aChar.uuid.uuidString)")
                }
            }
        } else {
            // debugPrint("No characteristics found for \(service.uuid.uuidString), can't listen to notifications")
        }
        
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
    }
    /*
     Invoked upon completion of a -[readValueForCharacteristic:] request or on the reception of a notification/indication.
     */
    func peripheral(_ aPeripheral:CBPeripheral, didUpdateValueFor characteristic:CBCharacteristic, error  :Error?) {
        
        //We received a value, if it did came from the calllback char, let's return it
        if (characteristic.uuid==mProfile?.CALLBACK_CHARACTERISTIC)
        {
            
            if error == nil && characteristic.value != nil {
                debugPrint("Received : \(characteristic.uuid.uuidString) \(self.hexString(characteristic.value!))")
                
                /* It is valid data, let's return it to our delegate */
                mDelegate?.packetReceived( RawPacketImpl(data: characteristic.value! , profile: mProfile!) ,  fromAddress : aPeripheral.identifier )
            }
        } else if(characteristic.uuid==CBUUID(string: "00002a26-0000-1000-8000-00805f9b34fb")) && characteristic.value != nil {
            if let version = String(bytes: characteristic.value!, encoding: .utf8){
                mFirmwareVersion = version
                print("Version: \(version)")
                mDelegate?.firmwareVersionReceived(DfuFirmwareTypes.application, version: version)
            }
            
        } else if(characteristic.uuid==CBUUID(string: "00002a28-0000-1000-8000-00805f9b34fb")) && characteristic.value != nil{
            if let version = String(bytes: characteristic.value!, encoding: .utf8){
                mSoftwareVersion = version
                print("Version: \(version)")
                mDelegate?.firmwareVersionReceived(DfuFirmwareTypes.softdevice, version: version)
            }
        }
    }
    
    /*
     Invoked upon completion of a -[writeValueForCharacteristic:] request
     */
    func peripheral(_ _peripheral:CBPeripheral, didWriteValueFor characteristic:CBCharacteristic, error :Error?) {
        
        if (error != nil) {
            // debugPrint("Failed to write value for characteristic \(characteristic), reason: \(error)")
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?){
        mDelegate?.receivedRSSIValue(RSSI)
    }
    
    func scanAndConnect(){
        self.scanAndConnectForAddreses(uuid: [mProfile!.CONTROL_SERVICE]);
    }
    
    // MARK: - NevoBT
    /**
     See NevoBT protocol
     */
    private func scanAndConnectForAddreses(uuid:[CBUUID]) {
        print("Scan and Connect for address \(mTryingToConnectPeripherals.count)")
        //We can't be sure if the Manager is ready, so let's try
        if(self.isBluetoothEnabled()) {
            let services:[CBUUID] = uuid
            //No address was specified, we'll search for devices with the right profile.
            //We'll try to connect to both known and nearby devices
            //Here we search for all nearby devices
            //We can't just search for all services, because that's not allowed when the app is in the background
            mManager?.scanForPeripherals(withServices: services,options:nil)
            // debugPrint("Scan started.")
            //The scan will stop X sec later
            //We scehduele or re-schdeuele the stop scanning
            mTimer?.invalidate()
            mTimer = Timer.scheduledTimer(timeInterval: SCANNING_DURATION, target: self, selector: #selector(NevoBTImpl.stopScan), userInfo: nil, repeats: false)
            //Here, we search for known devices
            if let systemConnected:[CBPeripheral] = mManager?.retrieveConnectedPeripherals(withServices: services) {
                for peripheral in systemConnected {
                    if (peripheral.state == CBPeripheralState.disconnected) {
                        //The given devices are known to the system and disconnected
                        //With a bit of luck the device is nearby and available
                        self.matchingPeripheralFound(peripheral)
                    }
                }
            }
        }
        
    }
    
    /**
     See NevoBT protocol
     */
    func connectToAddress(_ peripheralAddress : [UUID]) {
        //We can't be sure if the Manager is ready, so let's try
        if(self.isBluetoothEnabled()) {
            // debugPrint("Connecting to : \(peripheralAddress)")
            //Here, we try to retreive the given peripheral
            if let potentialMatches:[CBPeripheral] = mManager?.retrievePeripherals(withIdentifiers: peripheralAddress){
                for peripheral in potentialMatches {
                    if (peripheral.state == CBPeripheralState.disconnected) {
                        //The given devices are known to the system and disconnected
                        //With a bit of luck the device is nearby and available
                        self.matchingPeripheralFound(peripheral)
                    }
                }
            }
        }
    }
    
    /**
     See NevoBT protocol
     */
    func sendRequest(_ request:Request) {
        
        if let services:[CBService] = mPeripheral?.services{
            
            if( mProfile?.CALLBACK_CHARACTERISTIC != request.getTargetProfile().CALLBACK_CHARACTERISTIC ) {
                //We didn't subscribe to this profile's CallbackCharacteristic, there have to be a mistake somewhere
                // debugPrint("The target profile is incompatible with the profile given on this NevoBT's initalisation.")
                return ;
            }
            
            //Let's assume that you have already discovered the services
            for service:CBService in services {
                
                if(service.uuid == request.getTargetProfile().CONTROL_SERVICE) {
                    
                    if let characteristics:[CBCharacteristic] = service.characteristics{
                        
                        for charac:CBCharacteristic in characteristics {
                            
                            if(charac.uuid == request.getTargetProfile().CONTROL_CHARACTERISTIC) {
                                
                                if request.getRawDataEx().count == 0
                                {
                                    // debugPrint("Request raw data :\(request.getRawData())")
                                    //OTA control CHAR, need a response
                                    mPeripheral?.writeValue(request.getRawData(), for:charac,type:CBCharacteristicWriteType.withoutResponse)
                                }else{
                                    for data in request.getRawDataEx() {
                                        debugPrint("Request raw data Ex:\(Constants.NSData2Bytes(data))")
                                        mPeripheral?.writeValue(data, for:charac,type:CBCharacteristicWriteType.withoutResponse)
                                    }
                                }
                            }
                        }
                    } else {
                        // debugPrint("No Characteristics found for : \(service.uuid.uuidString), can't send packet")
                    }
                    
                }
            }
            
        } else {
            
            if(mPeripheral != nil) {
                // debugPrint("No services found for : \(self.mPeripheral), can't send packet")
            } else {
                // debugPrint("No peripheral connected, can't send packet")
            }
        }
    }
    
    /**
     See NevoBT protocol
     */
    func disconnect() {
        if let peripheral = mPeripheral{
            mManager?.cancelPeripheralConnection(peripheral)
            if let _ = peripheral.services {
                mDelegate?.connectionStateChanged(false, fromAddress: peripheral.identifier)
            }
        }
        setPeripheral(nil)
    }
    
    /**
     See NevoBT protocol
     */
    func isConnected() -> Bool {
        return ( mPeripheral != nil && mPeripheral!.state == CBPeripheralState.connected && isBluetoothEnabled() )
    }
    
    /**
     See NevoBT protocol
     */
    func getProfile() -> Profile {
        return mProfile!
    }
    
    /**
     See NevoBT protocol
     */
    func getFirmwareVersion() -> String {
        return mFirmwareVersion
    }
    
    /**
     See NevoBT protocol
     */
    func getSoftwareVersion() -> String {
        return mSoftwareVersion
    }
    
    // MARK: - Red RSSI NSTimer
    func redRSSI(_ timer:Timer){
        getRSSI()
    }
    
    // MARK: -This class of private function
    /**
     This peripheral is a good candidate, it has the right Services and hence we try to connect to it
     */
    fileprivate func matchingPeripheralFound( _ aPeripheral : CBPeripheral ){
        
        // debugPrint("Connecting to :\(aPeripheral.description)")
        
        //If it's not connected already, let's connect to it
        if(aPeripheral.state==CBPeripheralState.disconnected){
            
            //We have to save the peripheral, otherwise we will forget it
            //We don't knopw were this peripheral come from,
            //There might be for example 10 peripherals known to the device, but one only is in range
            //So we need to try to connect to sall of them, and hence we need to save all of them
            mTryingToConnectPeripherals.append(aPeripheral)
            if let manager = mManager {
                manager.connect(aPeripheral,options:nil)
                setPeripheral(aPeripheral)
            }
        }
        
    }
    
    fileprivate func setPeripheral(_ aPeripheral:CBPeripheral?) {
        //When setting a new peripheral, there are several steps to do first
        
        mPeripheral?.delegate = nil
        mPeripheral = aPeripheral
        mPeripheral?.delegate = self
    }
    
    /**
     Converts a binary value to HEX
     */
    fileprivate func hexString(_ data:Data) -> NSString {
        let str = NSMutableString()
        let bytes = UnsafeBufferPointer<UInt8>(start: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count), count:data.count)
        for byte in bytes {
            str.appendFormat("%02hhx", byte)
        }
        return str
    }
    
    // MARK: -This class of public function
    /**
     Stops the current scan
     */
    func stopScan() {
        mManager?.stopScan()
         // debugPrint("Scan stopped.")
    }
    
    /**
     Get the current connection device of RSSI values
     */
    func getRSSI(){
        mPeripheral?.readRSSI()
    }
    
    /**
     Uses CBCentralManager to check whether the current platform/hardware supports Bluetooth LE. An alert is raised if Bluetooth LE is not enabled or is not supported.
     */
    func isBluetoothEnabled() -> Bool {
        if(mManager == nil) {
            return false
        }
        
        if #available(iOS 10.0, *) {
            switch (mManager!.state)
            {
            case CBManagerState.poweredOn:
                return true
            default:
                return false
            }
        } else if mManager!.state.rawValue  == 5{
            return true
        }
        return false
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        DTUserDefaults.saveLog(message: "willRestoreState", key: "willRestoreState")
        if let array = dict[CBCentralManagerRestoredStatePeripheralsKey], let peripherals = array as? [CBPeripheral]{
            for peripheral in peripherals{
                // Should always be one but its ok. Let's just loop it.
                if (peripheral.state == CBPeripheralState.disconnected) {
                    central.connect(peripheral, options: nil)
                } else {
                    setPeripheral(peripheral)
                }
            }
        }
    }
}
