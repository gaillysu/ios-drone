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
}

