//
//  CockroachPositionCheckStrategy.swift
//  Drone
//
//  Created by Karl-John Chow on 4/10/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation

protocol CockroachPositionCheckStrategy {
    func execute(coordinationSet: CoordinateSet, whichCoordinate: Int, xMin:Int, xMax:Int, yMin:Int, yMax:Int, zMin:Int, zMax:Int) -> Bool 
}
