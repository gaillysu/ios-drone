//
//  NevoBT.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation

/*
NevoBT should do one thing : control the Core Bluetooth classes.
Out of this class, there should be no reference to the CB classes.
This class is rather low level, it doesn't handle timeout, disconnections etc...
It only can connect to one peripheral at a time
🚧🚧🚧Backbone Class : Modify with care🚧🚧🚧
*/
//This is a cat -----> 🐱
protocol NevoBT {
    /**
    Determines how long a scan is
    */
    var SCANNING_DURATION : NSTimeInterval { get }
    
    /**
    Tries to connect to any compatible peripheral
    */
    func scanAndConnect()
    
    /**
    Tries to connect to the given address
    */
    func connectToAddress(peripheralAddress : NSUUID)
    
    /**
    Disconnects the given peripheral
    */
    func disconnect()
    
    /**
    Sends a request to the connected peripheral.
    NOTE : The Request target profile 's Control characteristic can be different than the one used to initiate the NevoBT
    But the Callback Characteristic should be the same. Or the packet will be rejected for incompatibility.
    */
    func sendRequest(request: Request)
    
    /**
    Checks wether there is a peripheral currently connected
    */
    func isConnected() -> Bool
    
    /**
    Gets the currently saved profile
    Note that if you want to register a new profile, you have to delete this Nevo Object and recreate a new one
    */
    func getProfile() -> Profile
    
    /**
    Checks if the Bluetooth is avaikabke and enabled
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

    /**
    Get the current connection device of RSSI values
    */
    func getRSSI()

}

protocol NevoBTDelegate {
    /**
    Called when we received a valid packet

    fromAddress is the address of the peripheral that sent this packet
    Warning, this address is not a MAC address and may change in time

    */
    func packetReceived(rawpacket: RawPacket, fromAddress : NSUUID)
    
    /**
    Called when a peripheral connects or disconnects
    */
    func connectionStateChanged(isConnected : Bool, fromAddress : NSUUID!)
    
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