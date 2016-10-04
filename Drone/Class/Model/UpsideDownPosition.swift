//
//  NormalPosition.swift
//  Drone
//
//  Created by Karl-John Chow on 4/10/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation

class UpsideDownPosition: CockroachPositionProtocol {
//    Flipped upside down:X = [16..26], Y = [-7..-2] & Z = [-15..-4]
    let xMin:Int = 16;
    let xMax:Int = 26;
    let yMin:Int = -7;
    let yMax:Int = -2;
    let zMin:Int = -15;
    let zMax:Int = -4;
    let positionCheckStrategy:CockroachPositionCheckStrategy
    
    init() {
        self.positionCheckStrategy = CockroachPositionXYZMatchStrategy()
    }
    
    func matchesPosition(coordinationSet: CoordinateSet, whichCoordinate:Int) -> Bool{
        return positionCheckStrategy.execute(coordinationSet: coordinationSet, whichCoordinate: whichCoordinate, xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax, zMin: zMin, zMax: zMax)
    }
    
}
