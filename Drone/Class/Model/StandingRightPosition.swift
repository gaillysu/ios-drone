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

    let xMin:Int = 490;
    let xMax:Int = 550;
    let yMin:Int = -100;
    let yMax:Int = -40;
    let zMin:Int = -25;
    let zMax:Int = 55;
    let positionCheckStrategy:CockroachPositionCheckStrategy
    
    init() {
        self.positionCheckStrategy = CockroachPositionXYZMatchStrategy()
    }
    
    func matchesPosition(coordinationSet: CoordinateSet, whichCoordinate:Int) -> Bool{
        return positionCheckStrategy.execute(coordinationSet: coordinationSet, whichCoordinate: whichCoordinate, xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax, zMin: zMin, zMax: zMax)
    }
    
    func getCoordinatesForHuman() -> (x:CGFloat, y:CGFloat, z:CGFloat){
        return (1.57125,0.0,0.0)
    }
    
    func getDiscription() -> String{
        return "Standing Right Position"
    }
    
}
