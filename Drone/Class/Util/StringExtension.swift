//
//  StringExtension.swift
//  Drone
//
//  Created by Karl-John on 6/5/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
extension String {
    
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
    
//    let firstChar = someString[someString.startIndex]
//    let lastChar = someString[someString.index(before: someString.endIndex)]
//    let charAtIndex = someString[someString.index(someString.startIndex, offsetBy: 10)]
    
//    let range = someString.startIndex..<someString.index(someString.startIndex, offsetBy: 10)
//    let subtring = someString[range]

}

extension String {
    
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
}
