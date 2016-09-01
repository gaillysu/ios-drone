//
//  CockRoachDataUpdated.swift
//  Drone
//
//  Created by Karl Chow on 8/30/16.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation

class CockroachMasterChanged {
    
    let connected: Bool
    let address: NSUUID
    
    init(connected: Bool, address:NSUUID){
        self.connected = connected
        self.address = address
    }
}