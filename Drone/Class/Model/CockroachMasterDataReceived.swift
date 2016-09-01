//
//  CockroachDataReceived.swift
//  Drone
//
//  Created by Karl Chow on 8/30/16.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation

class CockroachMasterDataReceived {
    
    let coordinates: CoordinateSet
    let address : NSUUID
    let babyCockroachNumber: Int
    
    init(coordinates: CoordinateSet, address: NSUUID, babyCockroachNumber:Int){
        self.coordinates = coordinates
        self.address = address
        self.babyCockroachNumber = babyCockroachNumber
    }
}