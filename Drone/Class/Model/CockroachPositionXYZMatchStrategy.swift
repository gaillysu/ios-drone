//
//  CockroachPositionXYZMatchStrategy.swift
//  Drone
//
//  Created by Karl-John Chow on 4/10/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation

class CockroachPositionXYZMatchStrategy: CockroachPositionCheckStrategy {
    
    func execute(coordinationSet: CoordinateSet, whichCoordinate: Int, xMin:Int, xMax:Int, yMin:Int, yMax:Int, zMin:Int, zMax:Int) -> Bool {
        let coordinates = coordinationSet.getCoordinates(whichPacket: whichCoordinate)
        if coordinates.x < xMin || coordinates.x > xMax {
            return false
        }
        if coordinates.y < yMin || coordinates.y > yMax {
            return false
        }
        if coordinates.z < zMin || coordinates.z > zMax {
            return false
        }
        return true
    }
}
