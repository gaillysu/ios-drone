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
    
    dynamic var X0:Int = 0
    dynamic var X1:Int = 0
    dynamic var X2:Int = 0
    dynamic var Y0:Int = 0
    dynamic var Y1:Int = 0
    dynamic var Y2:Int = 0
    dynamic var Z0:Int = 0
    dynamic var Z1:Int = 0
    dynamic var Z2:Int = 0
    dynamic var sensorNumber = 0
    
    func setValues(_ cockroachPacket:CockRoachPacket){
        self.X0 = cockroachPacket.X0
        self.X1 = cockroachPacket.X1
        self.X2 = cockroachPacket.X2
        self.Y0 = cockroachPacket.Y0
        self.Y1 = cockroachPacket.Y1
        self.Y2 = cockroachPacket.Y2
        self.Z0 = cockroachPacket.Z0
        self.Z1 = cockroachPacket.Z1
        self.Z2 = cockroachPacket.Z2
        self.sensorNumber = cockroachPacket.cockRoachNumber
    }
    
    func getString () -> String{
        return "X0 = \(X0), X1 = \(X1), X2 = \(X2), Y0 = \(Y0), Y1 = \(Y1), Y2 = \(Y2), Z0 = \(Z0), Z1 = \(Z1), Z1 = \(Z1)"
    }
    
    func getAllCoordinates() -> [Int]{
        return [X0,X1,X2,Y0,Y1,Y2,Z0,Z1,Z2]
    }
    
    func equal(_ threshold:Int, otherCoordinateSet:CoordinateSet) -> Bool{
        for i in 0..<getAllCoordinates().count{
            if(!applicableMove(threshold, coordinate1: getAllCoordinates()[i], coordinate2: otherCoordinateSet.getAllCoordinates()[i])){
                return false
            }
        }
        return true
    }
    fileprivate func applicableMove(_ threshold:Int, coordinate1:Int, coordinate2:Int) -> Bool{
        if abs(coordinate1 - coordinate2) < threshold {
            return true
        }
        return false
    }
}
