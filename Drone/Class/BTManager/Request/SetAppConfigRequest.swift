//
//  AppConfigRequest.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/30.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

enum AppConfigApplicationID:UInt8 {
    case worldClock         = 0x01
    case activityTracking   = 0x02
    case weather            = 0x03
    case compass            = 0x10
}

enum AppConfigAppState:UInt8 {
    case on     = 0x01
    case off    = 0x00
}

class SetAppConfigRequest: DroneRequest {
    
    fileprivate var applicationID:UInt8 = AppConfigApplicationID.activityTracking.rawValue
    fileprivate var appState:UInt8 = AppConfigAppState.on.rawValue
    
    class func HEADER() -> UInt8 {
        return 0x04
    }
    
    init(appid:AppConfigApplicationID,state:AppConfigAppState) {
        super.init()
        applicationID = appid.rawValue
        appState = state.rawValue
    }

    override func getRawDataEx() -> [Data] {

        let values1 :[UInt8] = [0x80,SetAppConfigRequest.HEADER(), applicationID, appState, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

        return [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)]
    }
}
