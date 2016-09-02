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
    dynamic var totalAmountOfCockroaches = 0
    dynamic var createdDate:NSDate = NSDate()
    dynamic var startTime:NSDate = NSDate()
    dynamic var stopTime:NSDate = NSDate()
    
    let coordinateSeries = List<CoordinateSerie>()
}