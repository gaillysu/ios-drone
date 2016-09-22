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
    let address: UUID

    init(connected: Bool, address:UUID){
        self.connected = connected
        self.address = address
    }
}
