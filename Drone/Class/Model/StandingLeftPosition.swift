//
//  NormalPosition.swift
//  Drone
//
//  Created by Karl-John Chow on 4/10/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation

class StandingLeftPosition: CockroachPositionProtocol {
//  Standing on left side:	X = [-484..-478], Y = [-65..-57] & Z = [1..13]
    let xMin:Int = -484;
    let xMax:Int = -478;
    let yMin:Int = -65;
    let yMax:Int = -57;
    let zMin:Int = 1;
    let zMax:Int = 13;
    let positionCheckStrategy:CockroachPositionCheckStrategy
    
    init() {
        self.positionCheckStrategy = CockroachPositionXYZMatchStrategy()
    }
    
    func matchesPosition(coordinationSet: CoordinateSet, whichCoordinate:Int) -> Bool{
        return positionCheckStrategy.execute(coordinationSet: coordinationSet, whichCoordinate: whichCoordinate, xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax, zMin: zMin, zMax: zMax)
    }
    
}
