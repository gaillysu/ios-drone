//
//  AppConfigRequest.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/30.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class SetAppConfigRequest: NevoRequest {
    class func HEADER() -> UInt8 {
        return 0x04
    }

    override func getRawDataEx() -> NSArray {
        let isActivityTracking:UInt8 = 0x01
        let appState:UInt8 = 0x01
        let values1 :[UInt8] = [0x80,SetAppConfigRequest.HEADER(),
            isActivityTracking,
            appState,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        let values2 :[UInt8] = [0x80,SetAppConfigRequest.HEADER(),
            0x02,
            appState,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

        return NSArray(array: [NSData(bytes: values1, length: values1.count),NSData(bytes: values2, length: values2.count)])
    }
}
