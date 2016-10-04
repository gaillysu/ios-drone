//
//  NormalPosition.swift
//  Drone
//
//  Created by Karl-John Chow on 4/10/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation

class Standing: CockroachPositionProtocol {
    
//    Standing:	X = [-2..5], Y = [-2..5] & Z = [-490...-485]
    
    let xMin:Int = -2;
    let xMax:Int = 5;
    let yMin:Int = -2;
    let yMax:Int = 5;
    let zMin:Int = -490;
    let zMax:Int = -485;
    let positionCheckStrategy:CockroachPositionCheckStrategy
    
    init() {
        self.positionCheckStrategy = CockroachPositionXYZMatchStrategy()
    }
    
    func matchesPosition(coordinationSet: CoordinateSet, whichCoordinate:Int) -> Bool{
        return positionCheckStrategy.execute(coordinationSet: coordinationSet, whichCoordinate: whichCoordinate, xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax, zMin: zMin, zMax: zMax)
    }    
}
