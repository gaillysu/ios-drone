//
//  File.swift
//  Drone
//
//  Created by Karl-John on 29/8/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation

class CockRoachPacket:NSObject {
    
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
        self.X0 = Int(Int16(intData[1] << 7) | Int16(intData[0]))
        self.X1 = Int(Int16(intData[3] << 7) | Int16(intData[2]))
        self.X2 = Int(Int16(intData[5] << 7) | Int16(intData[4]))
        self.Y0 = Int(Int16(intData[7] << 7) | Int16(intData[6]))
        self.Y1 = Int(Int16(intData[9] << 7) | Int16(intData[8]))
        self.Y2 = Int(Int16(intData[11] << 7) | Int16(intData[10]))
        self.Z0 = Int(Int16(intData[13] << 7) | Int16(intData[12]))
        self.Z1 = Int(Int16(intData[15] << 7) | Int16(intData[14]))
        self.Z2 = Int(Int16(intData[17] << 7) | Int16(intData[16]))
//        self.X0 = Int(Int8(intData[0]) >> 2 * (intData[1] > 0 ? -1 : 1))
//        self.X1 = Int(Int8(intData[2] >> 2 * (intData[3] > 0 ? -1 : 1)))
//        self.X2 = Int(Int8(intData[4] >> 2 * (intData[5] > 0 ? -1 : 1)))
//        self.Y0 = Int(Int8(intData[6] >> 2 * (intData[7] > 0 ? -1 : 1)))
//        self.Y1 = Int(Int8(intData[8] >> 2 * (intData[9] > 0 ? -1 : 1)))
//        self.Y2 = Int(Int8(intData[10] >> 2 * (intData[11] > 0 ? -1 : 1)))
//        self.Z0 = Int(Int8(intData[12] >> 2 * (intData[13] > 0 ? -1 : 1)))
//        self.Z1 = Int(Int8(intData[14] >> 2 * (intData[15] > 0 ? -1 : 1)))
//        self.Z2 = Int(Int8(intData[16] >> 2 * (intData[17] > 0 ? -1 : 1)))
        self.cockRoachNumber = Int(intData[18])
     }
}
