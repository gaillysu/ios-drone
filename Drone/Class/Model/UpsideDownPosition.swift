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
    let xMin:Int = 10;
    let xMax:Int = 20;
    let yMin:Int = -10;
    let yMax:Int = 5;
    let zMin:Int = -20;
    let zMax:Int = 0;
    let positionCheckStrategy:CockroachPositionCheckStrategy
    
    init() {
        self.positionCheckStrategy = CockroachPositionXYZMatchStrategy()
    }
    
    func matchesPosition(coordinationSet: CoordinateSet, whichCoordinate:Int) -> Bool{
        return positionCheckStrategy.execute(coordinationSet: coordinationSet, whichCoordinate: whichCoordinate, xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax, zMin: zMin, zMax: zMax)
    }
    
    func getCoordinatesForHuman() -> (x:CGFloat, y:CGFloat, z:CGFloat){
        return (0.0,-1.57125,-1.57125)
    }
    
    func getDiscription() -> String{
        return "Upside Down Position"
    }

}
