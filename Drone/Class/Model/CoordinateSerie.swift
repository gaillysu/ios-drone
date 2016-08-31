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
    dynamic var address = ""
    let coordinateSets = List<CoordinateSet>()
}