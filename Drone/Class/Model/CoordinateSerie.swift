//
//  CoordinateSerie.swift
//  Drone
//
//  Created by Karl Chow on 8/31/16.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import RealmSwift

class CoordinateSerie: Object {
    dynamic var identifier = ""
    dynamic var cockroachNumber = -1
    let coordinateSets = List<CoordinateSet>()
}
