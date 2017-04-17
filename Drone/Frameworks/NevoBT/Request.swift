//
//  Request.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation

/*
Protocol that defines what's a Request.
🚧🚧🚧Backbone Class : Modify with care🚧🚧🚧
*/
protocol Request {
    
    /**
    The target profile. The connected device will receive this request only if it supports this profile.
    NOTE : The target profile 's Control characteristic can be different than the one used to initiate the NevoBT
    But the Callback Characteristic should be the same. Or the packet will be rejected for incompatibility.
    */
    func getTargetProfile() -> Profile
    
    /**
    Returns the raw packet to be sent via bluetooth
    */
    func getRawData() -> Data
    
    /**
    for Nevo/ Tracker, the communication protocol has 2 packet(0x00,0xFF)
    */
    func getRawDataEx() -> [Data]
}
