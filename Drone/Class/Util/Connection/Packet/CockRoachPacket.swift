//
//  File.swift
//  Drone
//
//  Created by Karl-John on 29/8/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation

class CockRoachPacket:NSObject {
    
    let data:[UInt8]
    
    init(data:NSData){
        self.data = NSData2Bytes(data)
    }
    
    //    X0 X0 Y0 Y0 Z0 Z0 X1 X1 Y1 Y1 Z1 Z1 X2 X2 Y2 Y2 Z2 Z2
    //    0  1  2  3  4  5  6  7  9  10 11 12 13 14 15 16 17 18
    
    func getX0() -> Int{
        return Int(data[0])
    }
    
    func getX1() -> Int{
        return Int(data[6])
    }
    
    func getX2() -> Int{
        return Int(data[13])
    }
    
    func getY0() -> Int{
        return Int(data[2])
    }
    
    func getY1() -> Int{
        return Int(data[9])
    }
    
    func getY2() -> Int{
        return Int(data[15])
    }
    
    func getZ0() -> Int{
        return Int(data[4])
    }
    
    func getZ1() -> Int{
        return Int(data[11])
    }
    
    func getZ2() -> Int{
        return Int(data[17])
    }

}