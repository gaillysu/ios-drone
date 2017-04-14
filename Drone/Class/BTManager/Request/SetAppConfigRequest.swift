//
//  AppConfigRequest.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/30.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

enum AppConfigApplicationID:Int {
    case worldClock         = 1
    case activityTracking   = 2
    case weather            = 3
    case compass            = 10
}

enum AppConfigAppState:Int {
    case on     = 1
    case off    = 0
}

class SetAppConfigRequest: DroneRequest {
    
    fileprivate var applicationID:Int = ApplicationID.ActivityTracking.rawValue
    fileprivate var appState:Int = AppState.on.rawValue
    
    class func HEADER() -> UInt8 {
        return 0x04
    }
    
    init(appid:AppConfigApplicationID,state:AppConfigAppState) {
        super.init()
        applicationID = appid.rawValue
        appState = state.rawValue
    }

    override func getRawDataEx() -> [Data] {

        let values1 :[UInt8] = [0x80,SetAppConfigRequest.HEADER(),
            UInt8(applicationID&0xFF),
            UInt8(appState&0xFF),0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

        return [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)]
    }
}
