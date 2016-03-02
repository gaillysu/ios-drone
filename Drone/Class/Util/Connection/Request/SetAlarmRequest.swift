//
//  SetAlarmRequest.swift
//  Nevo
//
//  Created by supernova on 15/2/12.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class SetAlarmRequest: NevoRequest {
   //0~23
    var alarmhour: [Int] = []
   //0~59
    var alarmmin:[Int] = []
    // true or false
    var alarmenable:[Bool] = []
    
    /*
    This header is the key by which this kind of packet is called.
    */
    class func HEADER() -> UInt8 {
        return 0x41
    }

    init(alarm:[Alarm])
    {
        for(var index:Int = 0; index<3; index++){
            if(alarm.count > index){
                alarmhour.append(alarm[index].getHour())
                alarmmin.append(alarm[index].getMinute())
                alarmenable.append(alarm[index].getEnable())
            }else{
                alarmhour.append(8)
                alarmmin.append(30)
                alarmenable.append(false)
            }
        }
    }
    
    override func getRawDataEx() -> NSArray {

        let values1 :[UInt8] = [0x00,SetAlarmRequest.HEADER(),
            UInt8(alarmhour[0]&0xFF),
            UInt8(alarmmin[0]&0xFF),
            UInt8(alarmenable[0] ? 7:0),
            UInt8(alarmhour[1]&0xFF),
            UInt8(alarmmin[1]&0xFF),
            UInt8(alarmenable[1] ? 7:0),
            UInt8(alarmhour[2]&0xFF),
            UInt8(alarmmin[2]&0xFF),
            UInt8(alarmenable[2] ? 7:0),
            0,0,0,0,0,0,0,0,0]
        
        let values2 :[UInt8] = [0xFF,SetAlarmRequest.HEADER(),
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        
        
        return NSArray(array: [NSData(bytes: values1, length: values1.count)
            ,NSData(bytes: values2, length: values2.count)])
    }

}


