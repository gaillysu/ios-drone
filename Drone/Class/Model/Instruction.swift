//
//  Exercise.swift
//  Drone
//
//  Created by Karl-John on 26/8/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import RealmSwift

class Instruction: Object {
    
    dynamic var id = 0
    dynamic var name = ""
    dynamic var createdDate:NSDate = NSDate()
    let X0Coordinates = List<Coordinate>()
    let X1Coordinates = List<Coordinate>()
    let X2Coordinates = List<Coordinate>()
    let Y0Coordinates = List<Coordinate>()
    let Y1Coordinates = List<Coordinate>()
    let Y2Coordinates = List<Coordinate>()
    let Z0Coordinates = List<Coordinate>()
    let Z1Coordinates = List<Coordinate>()
    let Z2Coordinates = List<Coordinate>()
    
}