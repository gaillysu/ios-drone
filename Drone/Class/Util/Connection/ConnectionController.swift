//
//  SyncController.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation

/*
The connection controller handles all the high level connection related tasks
It will reconnect the device, keep searching if it doesn't find it the first time
It also memorise the first device connected and automatically connects to it
🚧🚧🚧Backbone Class : Modify with care🚧🚧🚧
*/
protocol ConnectionController {

    /**
    set one  delegate,  this delegate comes from syncController 
    Layer struct: L1(NevoBT) -->L2 (ConnectionController,Single instance) -->L3 (syncController, single instance)
    -->L4(UI viewController), L1 is the base Layer, L4 is the top layer
    */
    func setDelegate(connectionDelegate: ConnectionControllerDelegate)
    
    /**
    Tries to connect to a Nevo
    Myabe it will scan for nearby nevo, maybe it will simply connect to a known nevo
    */
    func connect()
    
    /**
    Checks if there's a device currently connected
    */
    func isConnected() -> Bool
    
    /**
    Checks if there is a preffered device.
    If the answer is yes, then we will systematically connect to this device.
    If it is no, then we will scan for a new device
    */
    func hasSavedAddress() -> Bool
    
    /**
    Forgets the currently saved address.
    Next time connect is called, we will have to scan for nearby devices
    */
    func forgetSavedAddress()
    
    /**
    restore the saved address. BLE OTA use it
    Usage:forgetSavedAddress()/restoreSavedAddress(), if not call forgetSavedAddress()
    before call it, do nothing
    */
    func restoreSavedAddress()
    
    /**
    Tries to send a request, you can't be sure that it will effectively be sent
    */
    func sendRequest(request: Request)
    
    /**
    Enters the OTA mode. In this mode, it searchs for OTA enabled Nevo
    It won't connect to other Nevo and will stop sending regular nevo querries
    add second parameter, when BLE ota, auto disconnect by BLE peer, so no need disconnect it again
    */
    func setOTAMode(OTAMode:Bool,Disconnect:Bool)

    /**
    Checks whether the connection controller is in OTA mode
    While in OTA mode, the ConnectionController will stop responding to normal commands
    */
    func getOTAMode() -> Bool
    
    /**
    Checks whether the bluetooth is currently enabled
    */
    func isBluetoothEnabled() -> Bool
    
    /**
    get Nevo 's ble firmware version
    */
    func  getFirmwareVersion() -> NSString!
    
    /**
    get Nevo 's MCU software version
    */
    func  getSoftwareVersion() -> NSString!
    
}

protocol ConnectionControllerDelegate {
    
    /**
    Called when a packet is received from the device
    */
    func packetReceived(rawPacket: RawPacket)
    
    /**
    Called when a peripheral connects or disconnects
    */
    func connectionStateChanged(isConnected : Bool)
    
    /**
    Call when finish reading Firmware
    @parameter whichfirmware, firmware type
    @parameter version, return the version
    */
    func firmwareVersionReceived(whichfirmware:DfuFirmwareTypes, version:NSString)

    /**
    *  Receiving the current device signal strength value
    */
    func receivedRSSIValue(number:NSNumber)
}
