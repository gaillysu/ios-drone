//
//  CockroachDataReceived.swift
//  Drone
//
//  Created by Karl Chow on 8/30/16.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation

class CockroachDataReceived {
    
    let coordinates: CoordinateSet
    let address : NSUUID
    
    init(coordinates: CoordinateSet, address: NSUUID){
        self.coordinates = coordinates
        self.address = address
    }
}