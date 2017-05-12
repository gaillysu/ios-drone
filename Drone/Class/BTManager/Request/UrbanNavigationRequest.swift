//
//  UrbanNavigationRequest.swift
//  Drone
//
//  Created by Cloud on 2017/5/11.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit

class UrbanNavigationRequest: DroneRequest {
    enum UrbanNavigationOperation:UInt8 {
        case disable           = 0x00
        case enable            = 0x01
        case update            = 0x02
    }
    
    fileprivate var operation:UrbanNavigationOperation = .disable
    fileprivate var lat:Int = 0
    fileprivate var long:Int = 0
    fileprivate var name:String = ""
    fileprivate var distance:Int = 0 // unit "m"
    
    class func HEADER() -> UInt8 {
        return 0x35
    }
    
    init(latitude:Int,longitude:Int,mName:String) {
        super.init()
        operation = UrbanNavigationOperation.enable
        lat = latitude
        long = longitude
        name = mName
    }
    
    init(latitude:Int,longitude:Int,mDistance:Int) {
        super.init()
        operation = UrbanNavigationOperation.update
        lat = latitude
        long = longitude
        distance = mDistance
    }
    
    override init() {
        super.init()
        operation = UrbanNavigationOperation.disable

    }
    
    override func getRawDataEx() -> [Data] {
        switch operation {
        case .disable:
            let values1 :[UInt8] = [0x80,UrbanNavigationRequest.HEADER(),
                                    operation.rawValue,
                                    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
            return [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)]
        case .enable:
            let command:[UInt8] = [UInt8(lat&0xFF),
                                   UInt8(lat>>8&0xFF),
                                   UInt8(lat>>16&0xFF),
                                   UInt8(lat>>24&0xFF),
                                   UInt8(long&0xFF),
                                   UInt8(long>>8&0xFF),
                                   UInt8(long>>16&0xFF),
                                   UInt8(long>>24&0xFF)]
            let nameData:[UInt8] = Constants.NSData2Bytes(name.data(using: String.Encoding.utf8)!)
            
            let sendData = [UInt8(command.count)]+command+[UInt8(nameData.count)]+nameData
            
            let values1 :[UInt8] = [UrbanNavigationRequest.HEADER(),operation.rawValue]+sendData
            
            return Constants.splitPacketConverter(data: values1)
        case .update:
            let values1 :[UInt8] = [0x80,UrbanNavigationRequest.HEADER(),
                                    operation.rawValue,
                                    UInt8(12&0xFF),
                                    UInt8(lat&0xFF),
                                    UInt8(lat>>8&0xFF),
                                    UInt8(lat>>16&0xFF),
                                    UInt8(lat>>24&0xFF),
                                    UInt8(long&0xFF),
                                    UInt8(long>>8&0xFF),
                                    UInt8(long>>16&0xFF),
                                    UInt8(long>>24&0xFF),
                                    UInt8(distance&0xFF),
                                    UInt8(distance>>8&0xFF),
                                    UInt8(distance>>16&0xFF),
                                    UInt8(distance>>24&0xFF),0,0,0,0]
            return [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)]
        }
    }
    
    
}
