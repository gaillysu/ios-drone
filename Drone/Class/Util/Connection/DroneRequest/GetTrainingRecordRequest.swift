//
//  GetTrainingRecordRequest.swift
//  Drone
//
//  Created by leiyuncun on 16/3/23.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit

class GetTrainingRecordRequest: NevoRequest {
    class func HEADER() -> UInt8 {
        return 0x33
    }

    override func getRawDataEx() -> NSArray {

        let values1 :[UInt8] = [0x80,GetTrainingRecordRequest.HEADER(),
                                0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

        return NSArray(array: [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)])
    }
}
