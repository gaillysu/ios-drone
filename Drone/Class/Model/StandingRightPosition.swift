//
//  NormalPosition.swift
//  Drone
//
//  Created by Karl-John Chow on 4/10/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation

class StandingRightPosition: CockroachPositionProtocol {
    //Standing on right side: X = [-5..5], Y = [-15..-5] & Z = [-484...-480]

    let xMin:Int = -5;
    let xMax:Int = 5;
    let yMin:Int = -15;
    let yMax:Int = -5;
    let zMin:Int = -484;
    let zMax:Int = -480;
    let positionCheckStrategy:CockroachPositionCheckStrategy
    
    init() {
        self.positionCheckStrategy = CockroachPositionXYZMatchStrategy()
    }
    
    func matchesPosition(coordinationSet: CoordinateSet, whichCoordinate:Int) -> Bool{
        return positionCheckStrategy.execute(coordinationSet: coordinationSet, whichCoordinate: whichCoordinate, xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax, zMin: zMin, zMax: zMax)
    }
    
}
