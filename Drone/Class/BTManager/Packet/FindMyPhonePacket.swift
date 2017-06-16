//
//  FindMyPhonePacket.swift
//  Drone
//
//  Created by Cloud on 2017/6/16.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import Foundation

enum FindMyPhoneState:Int {
    case disable           = 0
    case enable            = 1
}

class FindMyPhonePacket: NSObject {

    class func HEADER() -> UInt8 {
        return 0x36
    }
    
    fileprivate var packetData:Data = Data()
    
    init(data:Data) {
        super.init()
        packetData = data
    }
    
    func getFindMyPhonePacket() -> Data {
        return packetData
    }
    
    func getFindMyPhoneState() -> FindMyPhoneState {
        let data:[UInt8] = Constants.NSData2Bytes(packetData)
        let status:Int = Int(data[2])
        return FindMyPhoneState(rawValue: status) ?? FindMyPhoneState.disable
    }
}
