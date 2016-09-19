//
//  NSDataExtension.swift
//  Drone
//
//  Created by Karl-John on 2/9/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation

extension Data {
    
    var hexString: String? {
        let buf = UnsafePointer<UInt8>(bytes)
        let charA = UInt8(UnicodeScalar("a").value)
        let char0 = UInt8(UnicodeScalar("0").value)
        
        func itoh(_ value: UInt8) -> UInt8 {
            return (value > 9) ? (charA + value - 10) : (char0 + value)
        }
        
        let ptr = UnsafeMutablePointer<UInt8>.allocate(capacity: count * 2)
        
        for i in 0 ..< count {
            ptr[i*2] = itoh((buf[i] >> 4) & 0xF)
            ptr[i*2+1] = itoh(buf[i] & 0xF)
        }
        
        return String(bytesNoCopy: ptr, length: count*2, encoding: String.Encoding.utf8, freeWhenDone: true)
    }
}
