//
//  CockroachPositionProtocol.swift
//  Drone
//
//  Created by Karl-John Chow on 4/10/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation

protocol CockroachPositionProtocol {
    func matchesPosition(coordinationSet: CoordinateSet, whichCoordinate:Int) -> Bool
    
    func getCoordinatesForHuman() -> (x:CGFloat, y:CGFloat, z:CGFloat)
    
    func getDiscription() -> String
}
