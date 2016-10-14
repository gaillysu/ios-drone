//
//  NormalPosition.swift
//  Drone
//
//  Created by Karl-John Chow on 4/10/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import UIKit

class StandingUpsideDown: CockroachPositionProtocol {
    //Standing upside down:	X = [0..3], Y = [-2..5] & Z = [-490...-485]

    let xMin:Int = 10;
    let xMax:Int = 35;
    let yMin:Int = -10;
    let yMax:Int = 10;
    let zMin:Int = 15;
    let zMax:Int = 35;
    
    let positionCheckStrategy:CockroachPositionCheckStrategy
    
    init() {
        self.positionCheckStrategy = CockroachPositionXYZMatchStrategy()
    }
    
    func matchesPosition(coordinationSet: CoordinateSet, whichCoordinate:Int) -> Bool{
        return positionCheckStrategy.execute(coordinationSet: coordinationSet, whichCoordinate: whichCoordinate, xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax, zMin: zMin, zMax: zMax)
    }
    
    func getCoordinatesForHuman() -> (x:CGFloat, y:CGFloat, z:CGFloat){
        return (3.1425,0.0,0.0)
    }
    
    func getDiscription() -> String{
        return "Standing Upside Down"
    }

}
