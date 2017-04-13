//
//  File.swift
//  Drone
//
//  Created by Karl-John on 29/8/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation

class CockRoachPacket:NSObject {
    
    let smallerThen:Int = 2047
    let minusBit:Int = 4096
    let X0:Int
    let X1:Int
    let X2:Int
    let Y0:Int
    let Y1:Int
    let Y2:Int
    let Z0:Int
    let Z1:Int
    let Z2:Int
    let cockRoachNumber:Int
    init(data:Data){

        let intData = NSData2BytesSigned(data)
        let convertedX0 = Int((Int16(intData[1]) << 8) | Int16(intData[0]))
        self.X0 = convertedX0 > smallerThen ? convertedX0 - minusBit : convertedX0
        let convertedY0 = Int((Int16(intData[3]) << 8) | Int16(intData[2]))
        self.Y0 = convertedY0 > smallerThen ? convertedY0 - minusBit : convertedY0
        let convertedZ0 = Int((Int16(intData[5]) << 8) | Int16(intData[4]))
        self.Z0 = convertedZ0 > smallerThen ? convertedZ0 - minusBit : convertedZ0
        let convertedX1 = Int((Int16(intData[7]) << 8) | Int16(intData[6]))
        self.X1 = convertedX1 > smallerThen ? convertedX1 - minusBit : convertedX1
        let convertedY1 = Int((Int16(intData[9]) << 8) | Int16(intData[8]))
        self.Y1 = convertedY1 > smallerThen ? convertedY1 - minusBit : convertedY1
        let convertedZ1 = Int((Int16(intData[11]) << 8) | Int16(intData[10]))
        self.Z1 = convertedZ1 > smallerThen ? convertedZ1 - minusBit : convertedZ1
        let convertedX2 = Int((Int16(intData[13]) << 8) | Int16(intData[12]))
        self.X2 = convertedX2 > smallerThen ? convertedX2 - minusBit : convertedX2
        let convertedY2 = Int((Int16(intData[15]) << 8) | Int16(intData[14]))
        self.Y2 = convertedY2 > smallerThen ? convertedY2 - minusBit : convertedY2
        let convertedZ2 = Int((Int16(intData[17]) << 8) | Int16(intData[16]))
        self.Z2 = convertedZ2 > smallerThen ? convertedZ2 - minusBit : convertedZ2
        self.cockRoachNumber = Int(intData[18])
     }
}
