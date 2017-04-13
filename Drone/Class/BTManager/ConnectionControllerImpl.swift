//
//  ConnectionControllerImpl.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation


/*
 See ConnectionController
 🚧🚧🚧Backbone Class : Modify with care🚧🚧🚧
 */
class ConnectionControllerImpl : NSObject, ConnectionController, NevoBTDelegate {
    /**
     Called when a peripheral connects or disconnects
     */
    
    
    fileprivate var mNevoBT:NevoBT?
    fileprivate var mDelegate:ConnectionControllerDelegate?
    
    /**
     This procedure explain the scan procedure
     Every X sec we will check if the peripheral is connected and retry to connect to it
     X changes depending on how long ago we scaned previously
     For example, we'll retry afetr 1 sec, then 10s, then 10s, then 10s, then 60s sec, 120s etc..
     */
    let SCAN_PROCEDURE:[Double] = [1,10,10,10,
                                   30,30,30,30,30,30,30,30,30,30,/*5min*/
        60,60,60,60,60,60,60,60,60,60,/*10min*/
        120,120,120,120,120,120,120,120,120,/*20min*/
        240,3600]
    
    /**
     This status is used to search in SCAN_PROCEDURE to know when is the next time we should scan
     */
    fileprivate var mScanProcedureStatus = 0
    
    /**
     This time handles the retry procedure
     */
    fileprivate var mRetryTimer:Timer?
    
    /**
     this parameter saved old BLE 's  address, when doing BLE OTA, the address has been changed to another one
     so, after finisned BLE ota, must restore it to normal 's address
     */
    fileprivate var savedAddress:String?
    
    /**
     No initialisation outside of this class, this is a singleton
     */
    override init() {
        super.init()
        
        mNevoBT = NevoBTImpl(externalDelegate: self, acceptableDevice: DroneProfile())
        setOTAMode(false,Disconnect:true)
    }
    
    /**
     See ConnectionController protocol
     */
    func setDelegate(_ delegate:ConnectionControllerDelegate) {
        debugPrint("New delegate : \(delegate)")
        
        mDelegate = delegate
    }
    
    /**
     See ConnectionController protocol
     */
    func connect(_ addres:[String]) {
        //If we're already connected, no need to reconnect
        if isConnected() {
            return;
        }
        
        //We're not connected, let's connect
        if addres.count>0 {
            debugPrint("We have a saved address, let's connect to it directly : \(addres)")
            var uuidArray:[UUID] = []
            for addresString:String in addres {
                let uuid = UUID(uuidString: addresString)
                if (uuid != nil) {
                    uuidArray.append(uuid!)
                }
            }
            mNevoBT?.connectToAddress(uuidArray)
        }
    }
    
    func connectNew(){
        if isConnected() {
            return;
        }
        mNevoBT?.scanAndConnect()
    }
    
    
    /**
     See NevoBTDelegate
     */
    func connectionStateChanged(_ isConnected : Bool, fromAddress : UUID!) {
        
        
        if (!isConnected) {
            connect([fromAddress.uuidString])
        } else {
            //Let's save this address
            mDelegate?.connectionStateChanged(isConnected,fromAddress:fromAddress.uuidString)
        }
        
    }
    
    /**
     See NevoBTDelegate
     */
    func firmwareVersionReceived(_ whichfirmware:DfuFirmwareTypes, version:NSString) {
        mDelegate?.firmwareVersionReceived(whichfirmware, version: version)
    }
    
    /**
     Receiving the current device signal strength value
     
     :param: number, Signal strength value
     */
    func receivedRSSIValue(_ number:NSNumber) {
        //AppTheme.DLog("Red RSSI Value:\(number)")
        mDelegate?.receivedRSSIValue(number)
    }
    
    /**
     See ConnectionController protocol
     */
    func disconnect() {
        mNevoBT!.disconnect()
        
        mRetryTimer?.invalidate()
        
        mRetryTimer = nil
    }
    
    /**
     See ConnectionController protocol
     */
    func isConnected() -> Bool {
        return mNevoBT!.isConnected()
    }
    
    /**
     See ConnectionController protocol
     */
    func sendRequest(_ request:Request) {
        
        mNevoBT?.sendRequest(request)
    }
    
    /**
     See ConnectionController protocol
     */
    func  getFirmwareVersion() -> NSString
    {
        return mNevoBT!.getFirmwareVersion()
    }
    
    /**
     See ConnectionController protocol
     */
    func  getSoftwareVersion() -> NSString
    {
        return mNevoBT!.getSoftwareVersion()
    }
    
    
    /**
     See NevoBTDelegate
     */
    func packetReceived(_ packet:RawPacket, fromAddress : UUID) {
        mDelegate?.packetReceived(packet)
    }
    
    
    /**
     See ConnectionController
     */
    func setOTAMode(_ OTAMode:Bool,Disconnect:Bool) {
        
        //No need to change the mode if we are already in OTA Mode
        if getOTAMode() == OTAMode {
            return;
        }
        if Disconnect
        {
            //cancel reconnect timer, make sure OTA can do connect by OTAcontroller
            disconnect()
        }
        
        //We don't set the profile on the NevoBT, because it could create too many issues
        //So we destroy the previous instance and recreate one
        mNevoBT = NevoBTImpl(externalDelegate: self, acceptableDevice: DroneProfile())
        
    }
    
    
    func getOTAMode() -> Bool {
        return false
    }
    
    func isBluetoothEnabled() -> Bool {
        if let enabled = mNevoBT?.isBluetoothEnabled() {
            return enabled
        }
        return false
    }
    
}
