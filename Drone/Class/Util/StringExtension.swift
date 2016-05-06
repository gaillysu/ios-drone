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
        let index = startIndex.advancedBy(integerIndex)
        return self[index]
    }
    
    subscript(integerRange: Range<Int>) -> String {
        let start = startIndex.advancedBy(integerRange.startIndex)
        let end = startIndex.advancedBy(integerRange.endIndex)
        let range = start..<end
        return self[range]
    }
}