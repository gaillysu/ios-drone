//
//  Vector.swift
//  Drone
//
//  Created by Karl-John on 26/9/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
class Vector {
    var X0:Int = 0
    var X1:Int = 0
    var X2:Int = 0
    var Y0:Int = 0
    var Y1:Int = 0
    var Y2:Int = 0
    var Z0:Int = 0
    var Z1:Int = 0
    var Z2:Int = 0
    
    init(X0:Int, X1:Int, X2:Int, Y0:Int, Y1:Int, Y2:Int, Z0:Int, Z1:Int, Z2:Int) {
        self.X0 = X0
        self.X1 = X1
        self.X2 = X2
        self.Y0 = Y0
        self.Y1 = Y1
        self.Y2 = Y2
        self.Z0 = Z0
        self.Z1 = Z1
        self.Z2 = Z2
    }
    
    init(withCoordinates left:CoordinateSet, right:CoordinateSet){
        self.X0 = left.X0 - right.X0
        self.X1 = left.X1 - right.X1
        self.X2 = left.X2 - right.X2
        self.Y0 = left.Y0 - right.Y0
        self.Y1 = left.Y1 - right.Y1
        self.Y2 = left.Y2 - right.Y2
        self.Z0 = left.Z0 - right.Z0
        self.Z1 = left.Z1 - right.Z1
        self.Z2 = left.Z2 - right.Z2
    }
    
    func getAllCoordinates() -> [Int]{
//        return [X0,X1,X2,Y0,Y1,Y2,Z0,Z1,Z2]
        return [X0,X1,Y0,Y1,Z0,Z1]
    }
    
    func equal(_ threshold:Int, otherVector:Vector) -> Bool{
        var passedCoordnates:Int = 0
        for index in 0..<getAllCoordinates().count{
            if self.applicableMove(threshold, coordinate1: getAllCoordinates()[index], coordinate2: otherVector.getAllCoordinates()[index]){
                passedCoordnates += 1
            }
        }
        return passedCoordnates == getAllCoordinates().count ? true : false
    }
    
    fileprivate func applicableMove(_ threshold:Int, coordinate1:Int, coordinate2:Int) -> Bool{
        if abs(coordinate1 - coordinate2) < threshold {
            return true
        }
        return false
    }
    
    func printVector(){
        print("Vector: \(getString())")
    }
    
    func getString() -> String{
        return "X0: \(X0) X1: \(X1) X2: \(X2) Y0: \(Y0) Y1: \(Y1) Y2: \(Y2) Z0: \(Z0) Z1: \(Z1) Z2: \(Z2)"
    }
}
