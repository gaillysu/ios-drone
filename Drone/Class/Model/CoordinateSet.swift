//
//  CoordinateSet.swift
//  Drone
//
//  Created by Karl-John on 29/8/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import RealmSwift
class CoordinateSet: Object {
    
    dynamic var X0Coordinates:Coordinate?
    dynamic var X1Coordinates:Coordinate?
    dynamic var X2Coordinates:Coordinate?
    dynamic var Y0Coordinates:Coordinate?
    dynamic var Y1Coordinates:Coordinate?
    dynamic var Y2Coordinates:Coordinate?
    dynamic var Z0Coordinates:Coordinate?
    dynamic var Z1Coordinates:Coordinate?
    dynamic var Z2Coordinates:Coordinate?
    
    func setValues(cockroachPacket:CockRoachPacket){
        var coordinate = Coordinate()
        coordinate.value = cockroachPacket.getX0()
        self.X0Coordinates = coordinate
        
        coordinate.value = cockroachPacket.getX1()
        self.X1Coordinates = coordinate
        
        coordinate.value = cockroachPacket.getX2()
        self.X2Coordinates = coordinate
        
        coordinate.value = cockroachPacket.getY0()
        self.Y0Coordinates = coordinate
        
        coordinate.value = cockroachPacket.getY1()
        self.Y1Coordinates = coordinate
        
        coordinate.value = cockroachPacket.getY2()
        self.Y2Coordinates = coordinate
        
        coordinate.value = cockroachPacket.getZ0()
        self.Z0Coordinates = coordinate
        
        coordinate.value = cockroachPacket.getZ1()
        self.Z1Coordinates = coordinate
        
        coordinate.value = cockroachPacket.getZ2()
        self.Z2Coordinates = coordinate
    }
    
    func getString () -> String{
        return "X0 = \(self.X0Coordinates!.value), X1 = \(X1Coordinates!.value), X2 = \(X2Coordinates!.value), Y0 = \(Y0Coordinates!.value), Y1 = \(Y1Coordinates!.value), Y2 = \(Y2Coordinates!.value), Z0 = \(Z0Coordinates!.value), Z1 = \(Z1Coordinates!.value), Z1 = \(Z1Coordinates!.value)"
    }
}