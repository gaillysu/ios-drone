//
//  SetWorldClockRequest.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/29.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class SetWorldClockRequest: DroneRequest {
    fileprivate let worldClockArray: [(cityName:String,gmtOffset:Float)]
    init(worldClockArray:[(cityName:String,gmtOffset:Float)]) {
        self.worldClockArray = worldClockArray
        super.init()
    }

    class func HEADER() -> UInt8 {
        return 0x06
    }

    override func getRawDataEx() -> [Data] {
        var nameDataArray:[[UInt8]] = []
        nameDataArray.reserveCapacity(16)
        var zoneArray:[Int] = []
        for worldClock:(cityName:String,gmtOffset:Float) in worldClockArray {
           let namedata:[UInt8] = NSData2Bytes(worldClock.cityName.data(using: String.Encoding.utf8)!)
            nameDataArray.append(namedata)
            zoneArray.append(Int(worldClock.gmtOffset * 4))//8.5
        }
         
        var values1 :[UInt8] = [SetWorldClockRequest.HEADER(),
            UInt8(worldClockArray.count&0xFF)]
        for (index,value) in zoneArray.enumerated() {
            values1.append(UInt8(value&0xFF))
            values1.append(UInt8(nameDataArray[index].count&0xFF))
            for data in nameDataArray[index] {
                values1.append(data)
            }
        }
        
        return Utility.splitPacketConverter(data: values1)
    }
}
