//
//  GetActivityRequest.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 18/2/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation

enum ActivityDataStatus:Int {
    case emptyData = 0,
    moreData = 1
}

class GetActivityRequest: NevoRequest {
    
    /*
    This header is the key by which this kind of packet is called.
    */
    class func HEADER() -> UInt8 {
        return 0x14
    }
    
    override func getRawDataEx() -> NSArray {
        
        let values1 :[UInt8] = [0x80,GetActivityRequest.HEADER(),
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

        return NSArray(array: [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)])
    }
}
