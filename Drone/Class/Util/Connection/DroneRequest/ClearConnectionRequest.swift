//
//  ClearConnectionRequest.swift
//  Drone
//
//  Created by leiyuncun on 16/5/18.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit

class ClearConnectionRequest: NevoRequest {

    class func HEADER() -> UInt8 {
        return 0x23
    }
    
    override func getRawDataEx() -> NSArray {
        
        let values1 :[UInt8] = [0x80,ClearConnectionRequest.HEADER(),
                                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        return NSArray(array: [NSData(bytes: values1, length: values1.count)])
    }
}
