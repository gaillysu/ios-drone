//
//  CockRoachDataUpdated.swift
//  Drone
//
//  Created by Karl Chow on 8/30/16.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation

class CockroachesChanged {
    
    let connected: Bool
    let address: NSUUID
    let devices: [NSUUID]
    
    init(connected: Bool, address:NSUUID, devices: [NSUUID]){
        self.connected = connected
        self.address = address
        self.devices = devices
    }
}