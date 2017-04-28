//
//  WatchInfoModel.swift
//  Drone
//
//  Created by Cloud on 2017/4/27.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit

class WatchInfoModel: NSObject {

    fileprivate var battery:PostBatteryStatus?
    
    init(batteryLevel:PostBatteryStatus?) {
        super.init()
        battery = batteryLevel
    }
    
    func getWatchInfo() -> (version:String,stateText:String,battery:String) {
        var versionString:String = "\(AppDelegate.getAppDelegate().getFirmwareVersion())"
        if versionString.isEmpty {
            versionString = "Not Connected"
        }
        
        if battery == nil {
            battery = PostBatteryStatus(state: -1, percent: 0)
        }
        
        var state:String = ""
        if AppDelegate.getAppDelegate().isConnected() {
            state = "Connected"
        }else{
            state = "Not Connected"
        }
        
        return (versionString,state,battery!.getStateString())
    }
}
