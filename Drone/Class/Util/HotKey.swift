//
//  HotKey.swift
//  Drone
//
//  Created by Karl-John Chow on 9/5/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import Foundation
class HotKey: NSObject {
    enum Feature:Int{
        case findYourPhone          = 1
        case disabledFindYourPhone  = -1
        case remoteCamera           = 2
        case disabledRemoteCamera   = -2
        case controlMusic           = 3
        case disabledControlMusic   = -3
        case disabled               = 0
        
        init(fromRawValue: Int){
            self = Feature(rawValue: fromRawValue) ?? .disabled
        }
    }    
}
