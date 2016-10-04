//
//  NormalPosition.swift
//  Drone
//
//  Created by Karl-John Chow on 4/10/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation

class NormalPosition: CockroachPositionProtocol {
    
    let xMin:Int = 15;
    let xMax:Int = 30;
    let yMin:Int = -6;
    let yMax:Int = 6;
    let zMin:Int = -501;
    let zMax:Int = -493;
    
    let positionCheckStrategy:CockroachPositionCheckStrategy
    
    init() {
        self.positionCheckStrategy = CockroachPositionXYZMatchStrategy()
    }
    
    func matchesPosition(coordinationSet: CoordinateSet, whichCoordinate:Int) -> Bool{
        return positionCheckStrategy.execute(coordinationSet: coordinationSet, whichCoordinate: whichCoordinate, xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax, zMin: zMin, zMax: zMax)
    }

    func getCoordinatesForHuman() -> (x:CGFloat, y:CGFloat, z:CGFloat){
        return (0.0,0.0,0.0)
    }
    
    func getDiscription() -> String{
        return "Normal Position"
    }
}

