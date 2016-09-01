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
    let nsDataVersion: NSData
    init(data:NSData){
        self.nsDataVersion = data
        self.data = NSData2Bytes(data)
        print("\(data.hexString)")
    }
    // 2212 4461
    //    X0 X0 Y0 Y0 Z0 Z0 X1 X1 Y1 Y1 Z1 Z1 X2 X2 Y2 Y2 Z2 Z2
    //    0  1  2  3  4  5  6  7  9  10 11 12 13 14 15 16 17 18
    
    func getX0() -> Int{
        let results =  UInt16(data[0]) + (UInt16(data[1] << 7))
        let convertedResults = Int(results)
        return convertedResults
    }
    
    func getX1() -> Int{
        let results =  UInt16(data[6]) + (UInt16(data[7] << 7))
        let convertedResults = Int(results)
        return convertedResults
    }
    
    func getX2() -> Int{
        let results =  UInt16(data[13]) + (UInt16(data[14] << 7))
        let convertedResults = Int(results)
        return convertedResults
    }
    
    func getY0() -> Int{
        let results =  UInt16(data[2]) + (UInt16(data[3] << 7))
        let convertedResults = Int(results)
        return convertedResults
    }
    
    func getY1() -> Int{
        let results =  UInt16(data[9]) + (UInt16(data[10] << 7))
        let convertedResults = Int(results)
        return convertedResults
    }
    
    func getY2() -> Int{
        let results =  UInt16(data[15]) + (UInt16(data[16] << 7))
        let convertedResults = Int(results)
        return convertedResults
    }
    
    func getZ0() -> Int{
        let results =  UInt16(data[4]) + (UInt16(data[5] << 7))
        let convertedResults = Int(results)
        return convertedResults
    }
    
    func getZ1() -> Int{
        let results =  UInt16(data[11]) + (UInt16(data[12] << 7))
        let convertedResults = Int(results)
        return convertedResults
    }
    
    func getZ2() -> Int{
        let results =  UInt16(data[17]) + (UInt16(data[18] << 7))
        let convertedResults = Int(results)
        return convertedResults
    }
    
}

extension NSData {
    
    var hexString: String? {
        let buf = UnsafePointer<UInt8>(bytes)
        let charA = UInt8(UnicodeScalar("a").value)
        let char0 = UInt8(UnicodeScalar("0").value)
        
        func itoh(value: UInt8) -> UInt8 {
            return (value > 9) ? (charA + value - 10) : (char0 + value)
        }
        
        let ptr = UnsafeMutablePointer<UInt8>.alloc(length * 2)
        
        for i in 0 ..< length {
            ptr[i*2] = itoh((buf[i] >> 4) & 0xF)
            ptr[i*2+1] = itoh(buf[i] & 0xF)
        }
        
        return String(bytesNoCopy: ptr, length: length*2, encoding: NSUTF8StringEncoding, freeWhenDone: true)
    }
}