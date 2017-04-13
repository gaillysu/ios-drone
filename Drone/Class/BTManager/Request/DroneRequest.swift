//
//  NevoRequest.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation

/*
All requests that should be sent to nevo have to extend this class
🚧🚧🚧Backbone Class : Modify with care🚧🚧🚧
*/
class DroneRequest : Request {
    func getTargetProfile() -> Profile {
        return DroneProfile()
    }
    
    func getRawData() -> Data {
        return Data()
    }
    
    func getRawDataEx() -> [Data] {
        return []
    }
    
}
