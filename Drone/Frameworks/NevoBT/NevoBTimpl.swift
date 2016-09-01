//
//  NevoBT.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation
import CoreBluetooth
import XCGLogger

/*
See NevoBT protocol
🚧🚧🚧Backbone Class : Modify with care🚧🚧🚧
*/
class NevoBTImpl : NSObject, NevoBT, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    /**
    The scanning time is 10 sec
    */
    let SCANNING_DURATION : NSTimeInterval = 10.000
    
    /**
    How long before we retry to connect when the central manager is powering up
    */
    private let RETRY_DURATION : NSTimeInterval = 0.500
    
    /**
    Gets notified when a periphare connects/disconnects and when we receive data
    */
    private var mDelegate : NevoBTDelegate?
    
    /**
    The central manager, we have to save it
    */
    private var mManager : CBCentralManager?
    
    /**
    The connected peripheral
    only one peripheral can be connected at a time
    */
    private var mPeripheral : CBPeripheral?
    
    private var cockroach : CBPeripheral?
    
    /**
    The list of peripherals we are trying to reach.
    There might be for example 10 peripherals known to the device, but one only is in range
    So we need to try to connect to all of them
    */
    private var mTryingToConnectPeripherals : [CBPeripheral] = []
    
    /**
    The GATT profile we are looking for
    */
    private var mProfile : Profile?
    
    /**
    The Stop scan timer
    */
    private var mTimer : NSTimer?
    
    /**
    Ble firmware version
    */
    private var mFirmwareVersion:NSString = ""
    
    /**
    MCU Software version
    */
    private var mSoftwareVersion:NSString = ""

    private var redRssiTimer:NSTimer = NSTimer()
    private var log = XCGLogger.defaultInstance()
    /**
    Basic constructor, just a Delegate handsake
    */
    
    private let cockRoach = (service: CBUUID(string:"F0BA3000-6CAC-4C99-9089-4B0A1DF45002"), characteristics: CBUUID(string:"F0BA5001-6CAC-4C99-9089-4B0A1DF45002"))
    
    init(externalDelegate : NevoBTDelegate, acceptableDevice : Profile) {
        super.init()
        mDelegate = externalDelegate

        mProfile = acceptableDevice

        mManager=CBCentralManager(delegate:self, queue:nil)
        
        mManager?.delegate = self
    }


    // MARK: - CBCentralManagerDelegate
    /**
    Invoked whenever the central manager's state is updated.
    */
    func centralManagerDidUpdateState(central : CBCentralManager) {
        self.isBluetoothEnabled()
    }
    
    /**
    Invoked when the central discovers a compatible device while scanning.
    */
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber){
    
        self.matchingPeripheralFound(peripheral)
    
    }

    /**
    Invoked whenever a connection is succesfully created with the peripheral.
    Discover available services on the peripheral and notifies our delegate
    */
    func centralManager(central: CBCentralManager, didConnectPeripheral aPeripheral: CBPeripheral) {

        log.debug("***Peripheral connected : \(aPeripheral.name)***")
        
        //We save this periphral for later use
        
        if(aPeripheral.services![0].UUID == cockRoach.service){
            cockroach = aPeripheral
            SWIFTEVENT_BUS_GOAL_COMPLETED
        }else{
            setPeripheral(aPeripheral)
        }
        
        
        mPeripheral?.discoverServices(nil)
        
        //We don't need to continue searching for peripherals, let's stop connecting to the others
        //We do so by forgetting them
        mTryingToConnectPeripherals = []

        if(redRssiTimer.valid){
            redRssiTimer.invalidate()
        }
        redRssiTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(NevoBTImpl.redRSSI(_:)), userInfo: nil, repeats: true)
    }

    /**
    Invoked whenever an existing connection with the peripheral is torn down.
    Reset local variables and notifies our delegate
    */
    func centralManager(central: CBCentralManager, didDisconnectPeripheral aPeripheral: CBPeripheral, error : NSError?) {

        log.debug("***Peripheral disconnected : \(aPeripheral.name)***")

        if(error != nil) {
            log.debug("Error : \(error!.localizedDescription) for peripheral : \(aPeripheral.name)")
        }


        //Let's forget this device
        if let localPeripheral = mPeripheral{
            if localPeripheral.identifier == aPeripheral.identifier{
                setPeripheral(nil)
                mDelegate?.connectionStateChanged(false, fromAddress: aPeripheral.identifier)
            }else{
                mDelegate?.cockRoachesChanged(false, fromAddress: aPeripheral.identifier)
                removeCockroach(aPeripheral)
            }
        }
    
        if(redRssiTimer.valid){
            redRssiTimer.invalidate()
        }
    }

    // MARK: - CBPeripheralDelegate
    /*
    Invoked upon completion of a -[discoverServices:] request.
    Discover available characteristics on interested services
    */
    func peripheral(aPeripheral: CBPeripheral, didDiscoverServices error: NSError?) {
    
        //Our aim is to subscribe to the callback characteristic, so we'll have to find it in the control service
        if let services:[CBService] = aPeripheral.services{
        
            for aService:CBService in services {
                debugPrint("Service found with UUID : \(aService.UUID.UUIDString)")
    
                if (aService.UUID == mProfile?.CONTROL_SERVICE) {
                    aPeripheral.discoverCharacteristics(nil,forService:aService)
                }
                //device info service
                else if (aService.UUID == CBUUID(string: "0000180a-0000-1000-8000-00805f9b34fb")) {
                    aPeripheral.discoverCharacteristics(nil,forService:aService)
                }else if(aService.UUID == cockRoach.service){
                    // this service characteristic is for the cockroach.
                    aPeripheral.discoverCharacteristics(nil,forService:aService)
                }
            }
        } else {
            log.debug("No services found for \(aPeripheral.identifier.UUIDString), connection impossible")
        }
    }
    
    /*
    Invoked upon completion of a -[discoverCharacteristics:forService:] request.
    Perform appropriate operations on interested characteristics
    */
    func peripheral(aPeripheral:CBPeripheral, didDiscoverCharacteristicsForService service:CBService, error :NSError?) {
    
        log.debug("Service : \(service.UUID.UUIDString)")
    
        if let characteristics:[CBCharacteristic] = service.characteristics {
            for aChar:CBCharacteristic in characteristics {
                mPeripheral?.setNotifyValue(true,forCharacteristic:aChar)
                if(aChar.UUID==mProfile?.CALLBACK_CHARACTERISTIC ) {
                    mPeripheral?.setNotifyValue(true,forCharacteristic:aChar)
            
                    log.debug("Callback char : \(aChar.UUID.UUIDString)")
                    mDelegate?.connectionStateChanged(true, fromAddress: aPeripheral.identifier)
                } else if(aChar.UUID==CBUUID(string: "00002a26-0000-1000-8000-00805f9b34fb")) {
                    mPeripheral?.readValueForCharacteristic(aChar)
                    log.debug("read firmware version char : \(aChar.UUID.UUIDString)")
                } else if(aChar.UUID==CBUUID(string: "00002a28-0000-1000-8000-00805f9b34fb")) {
                    mPeripheral?.readValueForCharacteristic(aChar)
                    log.debug("read software version char : \(aChar.UUID.UUIDString)")
                } else if(aChar.UUID==cockRoach.characteristics) {
                    // this characteristic is for the cockroach.
                    mDelegate?.cockRoachesChanged(true, fromAddress: aPeripheral.identifier)
                    mPeripheral?.readValueForCharacteristic(aChar)
                }
            }
        } else {
            log.debug("No characteristics found for \(service.UUID.UUIDString), can't listen to notifications")
        }
      
    
    }
    
    /*
    Invoked upon completion of a -[readValueForCharacteristic:] request or on the reception of a notification/indication.
    */
    func peripheral(aPeripheral:CBPeripheral, didUpdateValueForCharacteristic characteristic:CBCharacteristic, error  :NSError?) {
        
        //We received a value, if it did came from the calllback char, let's return it
        if (characteristic.UUID==mProfile?.CALLBACK_CHARACTERISTIC)
        {
            
            if error == nil && characteristic.value != nil {
                log.debug("Received : \(characteristic.UUID.UUIDString) \(hexString(characteristic.value!))")
                
                /* It is valid data, let's return it to our delegate */
                mDelegate?.packetReceived( RawPacketImpl(data: characteristic.value! , profile: mProfile!) ,  fromAddress : aPeripheral.identifier )
            }
        } else if(characteristic.UUID==CBUUID(string: "00002a26-0000-1000-8000-00805f9b34fb")) {
            mFirmwareVersion = NSString(data: characteristic.value!, encoding: NSUTF8StringEncoding)!
            log.debug("get firmware version char : \(characteristic.UUID.UUIDString), version : \(mFirmwareVersion)")
            //tell OTA new version
            mDelegate?.firmwareVersionReceived(DfuFirmwareTypes.APPLICATION, version: mFirmwareVersion)
        } else if(characteristic.UUID==CBUUID(string: "00002a28-0000-1000-8000-00805f9b34fb")) {
            if(characteristic.value != nil){
                mSoftwareVersion = NSString(data: characteristic.value!, encoding: NSUTF8StringEncoding)!
            }
            log.debug("get software version char : \(characteristic.UUID.UUIDString), version : \(mSoftwareVersion)")
            mDelegate?.firmwareVersionReceived(DfuFirmwareTypes.SOFTDEVICE, version: mSoftwareVersion)
        } else if(characteristic.UUID==cockRoach.characteristics) {
            let coordinateSet = CoordinateSet()
            coordinateSet.setValues(CockRoachPacket(data: characteristic.value!))
            // GET VERSION OF THE BABY COCKROACH PLEASE
            mDelegate?.cockRoachDataReceived(coordinateSet, withAddress: aPeripheral.identifier,forBabyCockroach: 0)
        }
    }
    
    /*
    Invoked upon completion of a -[writeValueForCharacteristic:] request
    */
    func peripheral(_peripheral:CBPeripheral, didWriteValueForCharacteristic characteristic:CBCharacteristic, error :NSError?) {
    
        if (error != nil) {
            log.debug("Failed to write value for characteristic \(characteristic), reason: \(error)")
        } else {
            log.debug("Did write value for characterstic \(characteristic), new value: \(characteristic.value)")
        }

    }

    func peripheral(peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: NSError?){
        mDelegate?.receivedRSSIValue(RSSI)
    }

    // MARK: - NevoBT
    /**
    See NevoBT protocol
    */
    func scanAndConnect() {

        //We can't be sure if the Manager is ready, so let's try
        if(self.isBluetoothEnabled()) {
            let services:[CBUUID] = [mProfile!.CONTROL_SERVICE]
            //No address was specified, we'll search for devices with the right profile.
            //We'll try to connect to both known and nearby devices
            //Here we search for all nearby devices
            //We can't just search for all services, because that's not allowed when the app is in the background
            mManager?.scanForPeripheralsWithServices(services,options:nil)
            log.debug("Scan started.")
            //The scan will stop X sec later
            //We scehduele or re-schdeuele the stop scanning
            mTimer?.invalidate()
            mTimer = NSTimer.scheduledTimerWithTimeInterval(SCANNING_DURATION, target: self, selector: #selector(NevoBTImpl.stopScan), userInfo: nil, repeats: false)
            //Here, we search for known devices
            if let systemConnected:[CBPeripheral] = mManager?.retrieveConnectedPeripheralsWithServices(services) {
                for peripheral in systemConnected {
                    if (peripheral.state == CBPeripheralState.Disconnected) {
                        //The given devices are known to the system and disconnected
                        //With a bit of luck the device is nearby and available
                        self.matchingPeripheralFound(peripheral)
                    }
                }
            }
        } else {
            //Maybe the Manager is not ready yet, let's try again after a delay
//            log.debug("Bluetooth Manager unavailable or not initialised, let's retry after a delay")

            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(RETRY_DURATION * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                self.scanAndConnect()
            })
        }

    }

    /**
    See NevoBT protocol
    */
    func connectToAddress(peripheralAddress : [NSUUID]) {

        //We can't be sure if the Manager is ready, so let's try
        if(self.isBluetoothEnabled()) {
            log.debug("Connecting to : \(peripheralAddress)")
            //Here, we try to retreive the given peripheral
            if let potentialMatches:[CBPeripheral] = mManager?.retrievePeripheralsWithIdentifiers(peripheralAddress){
                for peripheral in potentialMatches {
                    if (peripheral.state == CBPeripheralState.Disconnected) {
                        //The given devices are known to the system and disconnected
                        //With a bit of luck the device is nearby and available
                        self.matchingPeripheralFound(peripheral)
                    }
                }
            }
        } else {
            //Maybe the Manager is not ready yet, let's try again after a delay
//            log.debug("Bluetooth Manager unavailable or not initialised, let's retry after a delay")
            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(RETRY_DURATION * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                self.connectToAddress(peripheralAddress)
            })
        }
    }

    /**
    See NevoBT protocol
    */
    func sendRequest(request:Request) {

        if let services:[CBService] = mPeripheral?.services{
            
            if( mProfile?.CALLBACK_CHARACTERISTIC != request.getTargetProfile().CALLBACK_CHARACTERISTIC ) {
                //We didn't subscribe to this profile's CallbackCharacteristic, there have to be a mistake somewhere
                log.debug("The target profile is incompatible with the profile given on this NevoBT's initalisation.")
                return ;
            }
    
            //Let's assume that you have already discovered the services
            for service:CBService in services {
                
                if(service.UUID == request.getTargetProfile().CONTROL_SERVICE) {
                    
                    if let characteristics:[CBCharacteristic] = service.characteristics{
                    
                        for charac:CBCharacteristic in characteristics {
                        
                            if(charac.UUID == request.getTargetProfile().CONTROL_CHARACTERISTIC) {
    
                                if request.getRawDataEx().count == 0
                                {
                                    log.debug("Request raw data :\(request.getRawData())")
                                    //OTA control CHAR, need a response
                                    if mProfile is NevoOTAControllerProfile && request.getTargetProfile().CONTROL_CHARACTERISTIC == mProfile?.CONTROL_CHARACTERISTIC
                                    {
                                        mPeripheral?.writeValue(request.getRawData(),forCharacteristic:charac,type:CBCharacteristicWriteType.WithResponse)
                                    }
                                    else
                                    {
                                        mPeripheral?.writeValue(request.getRawData(),forCharacteristic:charac,type:CBCharacteristicWriteType.WithoutResponse)
                                    }
                                }else{
                                    for data in request.getRawDataEx() {
                                        log.debug("Request raw data Ex:\(data)")
                                        mPeripheral?.writeValue(data as! NSData,forCharacteristic:charac,type:CBCharacteristicWriteType.WithoutResponse)
                                    }
                                }
                            }
                        }
                    } else {
                        log.debug("No Characteristics found for : \(service.UUID.UUIDString), can't send packet")
                    }
                    
                }
            }

        } else {
            
            if(mPeripheral != nil) {
                log.debug("No services found for : \(mPeripheral), can't send packet")
            } else {
                log.debug("No peripheral connected, can't send packet")
            }
        }
    }
    
    /**
    See NevoBT protocol
    */
    func disconnect() {
        if(mPeripheral != nil)
        {
            mManager?.cancelPeripheralConnection(mPeripheral!)
            mDelegate?.connectionStateChanged(false, fromAddress: mPeripheral?.identifier)
        }
        setPeripheral(nil)
    }
    
    /**
    See NevoBT protocol
    */
    func isConnected() -> Bool {
        return ( mPeripheral != nil && mPeripheral!.state == CBPeripheralState.Connected && isBluetoothEnabled() )
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
    func getFirmwareVersion() -> NSString {
        return mFirmwareVersion
    }
    
    /**
    See NevoBT protocol
    */
    func getSoftwareVersion() -> NSString {
        return mSoftwareVersion
    }

    // MARK: - Red RSSI NSTimer
    func redRSSI(timer:NSTimer){
        getRSSI()
    }

    // MARK: -This class of private function
    /**
    This peripheral is a good candidate, it has the right Services and hence we try to connect to it
    */
    private func matchingPeripheralFound( aPeripheral : CBPeripheral ){

        log.debug("Connecting to :\(aPeripheral.description)")

        //If it's not connected already, let's connect to it
        if(aPeripheral.state==CBPeripheralState.Disconnected){

            //We have to save the peripheral, otherwise we will forget it
            //We don't knopw were this peripheral come from,
            //There might be for example 10 peripherals known to the device, but one only is in range
            //So we need to try to connect to all of them, and hence we need to save all of them
            mTryingToConnectPeripherals.append(aPeripheral)

            mManager?.connectPeripheral(aPeripheral,options:nil)

        }

    }

    private func setPeripheral(aPeripheral:CBPeripheral?) {
        //When setting a new peripheral, there are several steps to do first

        mPeripheral?.delegate = nil

        mPeripheral = aPeripheral
        mPeripheral?.delegate = self
    }

    /**
    Converts a binary value to HEX
    */
    private func hexString(data:NSData) -> NSString {
        let str = NSMutableString()
        let bytes = UnsafeBufferPointer<UInt8>(start: UnsafePointer(data.bytes), count:data.length)
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

        log.debug("Scan stopped.")

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

        switch (mManager!.state)
        {

        case CBCentralManagerState.PoweredOn:
            return true

        case CBCentralManagerState.Unsupported:
//            log.debug("The platform/hardware doesn't support Bluetooth Low Energy.")
            break

        case CBCentralManagerState.Unauthorized:
//            log.debug("The app is not authorized to use Bluetooth Low Energy.")
            break

        case CBCentralManagerState.PoweredOff:
//            log.debug("Bluetooth is currently powered off.")
            break

        default:
//            log.debug("Unknown device state")
            break
        }
        return false
    }
    
    func removeCockroach(aPeripheral: CBPeripheral){
        if let unpackedcockroach = self.cockroach{
            if unpackedcockroach.identifier == aPeripheral.identifier{
                self.cockroach = nil
            }
        }
    }
    
    func getCockroachesUUID() -> NSUUID?{
        if let unpackedCockroach = cockroach {
            return unpackedCockroach.identifier
        }
        return nil
    }
}