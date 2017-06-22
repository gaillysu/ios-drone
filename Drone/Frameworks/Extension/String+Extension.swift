//
//  Int+Extension.swift
//  Nevo
//
//  Created by leiyuncun on 16/9/29.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import Foundation

extension String {
    func toInt() -> Int {
        return NSString(format: "%@", self).integerValue
    }
    
    func toDouble() -> Double {
        return NSString(format: "%@", self).doubleValue
    }
    
    func toFloat() -> Float {
        return NSString(format: "%@", self).floatValue
    }
    
    var length:Int {
        get{
            return NSString(format: "%@", self).length
        }
    }
    
    subscript(integerIndex: Int) -> Character {
        let index = characters.index(startIndex, offsetBy: integerIndex)
        return self[index]
    }
    
    subscript(integerRange: Range<Int>) -> String {
        let start = characters.index(startIndex, offsetBy: integerRange.lowerBound)
        let end = characters.index(startIndex, offsetBy: integerRange.upperBound)
        let range = start..<end
        return self[range]
    }
    
    func dataFromHexString() -> NSData? {
        guard let chars = cString(
            
            using: String.Encoding.utf8) else { return nil}
        var i = 0
        let length = characters.count
        
        let data = NSMutableData(capacity: length/2)
        var byteChars: [CChar] = [0, 0, 0]
        
        var wholeByte: CUnsignedLong = 0
        
        while i < length {
            byteChars[0] = chars[i]
            i+=1
            byteChars[1] = chars[i]
            i+=1
            wholeByte = strtoul(byteChars, nil, 16)
            data?.append(&wholeByte, length: 1)
        }
        
        return data
    }
    
    func binary2dec() -> Int {
        var sum = 0
        for c in self.characters {
            sum = sum * 2 + Int("\(c)")!
        }
        return sum
    }
}
