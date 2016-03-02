//
//  TestMode.swift
//  Nevo
//
//  Created by leiyuncun on 15/8/3.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class TestMode: NSObject {
    private var packetData:[NSData]?//所属按键数据包
    private var pressedData:[NSData]?//松开按键接收数据包

    class func shareInstance(datas:[NSData])->TestMode{
        struct TestModeSingleton{
            static var predicate:dispatch_once_t = 0
            static var instance:TestMode?
        }
        dispatch_once(&TestModeSingleton.predicate,{
            TestModeSingleton.instance=TestMode()
            }
        )
        TestModeSingleton.instance?.setPacketData(datas)
        return TestModeSingleton.instance!
    }

    override init() {

    }

    func setPacketData(data:[NSData]){
        let header:UInt8 = NSData2Bytes(data[0])[1]
        let instruction:UInt8 = NSData2Bytes(data[0])[2]
        if(header == 0xF1 && (instruction == 0x02)){
            pressedData = data;
            packetData?.removeAll(keepCapacity: true)
        }

        if(header == 0xF1 && (instruction == 0x00)){
            packetData = data;
        }
    }

    func isTestModel()->Bool {
        if(pressedData?.count>0 && packetData?.count>0){
            let header:UInt8 = NSData2Bytes(pressedData![0])[1]
            let instruction:UInt8 = NSData2Bytes(pressedData![0])[2]

            let isModelHeader:UInt8 = NSData2Bytes(packetData![0])[1]
            let isModelInstruction:UInt8 = NSData2Bytes(packetData![0])[2]

            if(header == 0xF1 && (instruction == 0x02) && isModelHeader == 0xF1 && (isModelInstruction == 0x00)){
                pressedData?.removeAll(keepCapacity: true)
                packetData?.removeAll(keepCapacity: true)
                return true;
            }else{
                return false
            }
        }else{
            return false;
        }
    }

}
