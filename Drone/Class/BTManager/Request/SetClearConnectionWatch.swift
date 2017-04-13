//
//  SetClearConnectionWatch.swift
//  Drone
//
//  Created by leiyuncun on 16/3/14.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit

class SetClearConnectionWatch: DroneRequest {
    /**
     The <Clear Connection> command is a mean for the Hub to make the Device drop the connection and discard any pairing keys that might have been exchanged between the devices. The <Clear Connection> command does not define neither a request nor a response payload.  Upon receiving the <Clear Connection> command, right after responding with the proper ACK, the Device shall drop the connection and forget all pairing keys associated with the connected Hub.
     */
    class func HEADER() -> UInt8 {
        return 0x23
    }

    override func getRawDataEx() -> [Data] {
        let values1 :[UInt8] = [0x80,SetClearConnectionWatch.HEADER(),
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        return [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)]
    }
}
