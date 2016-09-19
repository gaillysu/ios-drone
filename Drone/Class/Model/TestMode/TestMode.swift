//
//  TestMode.swift
//  Nevo
//
//  Created by leiyuncun on 15/8/3.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class TestMode: NSObject {
    private static var __once: () = {
            TestModeSingleton.instance=TestMode()
            }()
    fileprivate var packetData:[Data]?//所属按键数据包
    fileprivate var pressedData:[Data]?//松开按键接收数据包

    class func shareInstance(_ datas:[Data])->TestMode{
        struct TestModeSingleton{
            static var predicate:Int = 0
            static var instance:TestMode?
        }
        _ = TestMode.__once
        TestModeSingleton.instance?.setPacketData(datas)
        return TestModeSingleton.instance!
    }

    override init() {

    }

    func setPacketData(_ data:[Data]){
        let header:UInt8 = NSData2Bytes(data[0])[1]
        let instruction:UInt8 = NSData2Bytes(data[0])[2]
        if(header == 0xF1 && (instruction == 0x02)){
            pressedData = data;
            packetData?.removeAll(keepingCapacity: true)
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
                pressedData?.removeAll(keepingCapacity: true)
                packetData?.removeAll(keepingCapacity: true)
                return true;
            }else{
                return false
            }
        }else{
            return false;
        }
    }

}
