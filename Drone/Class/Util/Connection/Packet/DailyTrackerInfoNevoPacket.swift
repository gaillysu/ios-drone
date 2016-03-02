//
//  DailyTrackerInfoNevoPacket.swift
//  Nevo
//
//  Created by supernova on 15/3/17.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class DailyTrackerInfoNevoPacket: NevoPacket {
         
    /**
    return Tracker history summary infomation, MAX total 7 days(include Today)
    the actually days is saved by [DailyHistory].count
    */
    func getDailyTrackerInfo() ->[DailyHistory]
    {
            var days:[DailyHistory] = []
        
            let total:Int = Int(NSData2Bytes(getPackets()[1])[12])
            var year:Int = 0
            var month:Int = 0
            var day:Int = 0
            
            for (var i:Int = 0; i<total; i++)
            {
                let format:NSDateFormatter = NSDateFormatter()
                format.dateFormat = "yyyyMMddHHmmss"
                
                if(i<=3)
                {
                    year  = Int(NSData2Bytes(getPackets()[0])[2+4*i] ) + Int(NSData2Bytes(getPackets()[0])[3+4*i])<<8
                    month = Int(NSData2Bytes(getPackets()[0])[4+4*i] )
                    day   = Int(NSData2Bytes(getPackets()[0])[5+4*i] )
                }
                else if(i == 4)
                {
                    year  = Int(NSData2Bytes(getPackets()[0])[2+4*i] ) + Int(NSData2Bytes(getPackets()[0])[3+4*i])<<8
                    month = Int(NSData2Bytes(getPackets()[1])[2] )
                    day   = Int(NSData2Bytes(getPackets()[1])[3] )
                }
                else if(i == 5)
                {
                    year  = Int(NSData2Bytes(getPackets()[1])[4] ) + Int(NSData2Bytes(getPackets()[1])[5])<<8
                    month = Int(NSData2Bytes(getPackets()[1])[6] )
                    day   = Int(NSData2Bytes(getPackets()[1])[7] )
                }
                else if(i == 6)
                {
                    year  = Int(NSData2Bytes(getPackets()[1])[8] ) + Int(NSData2Bytes(getPackets()[1])[9])<<8
                    month = Int(NSData2Bytes(getPackets()[1])[10] )
                    day   = Int(NSData2Bytes(getPackets()[1])[11] )
                }
                
                //vaild year,month, day
                if((year>1970 && year<2050)  && (month>=1 && month<=12) && (day>=1 && day<=31))
                {
                    //20150316
                    let mdata:String = String(format: "\(year)%02d%02d000000",month,day)
                    let date:NSDate = format.dateFromString(mdata)!
                    days.append(DailyHistory(date:date))
                }
                
            }
            
            
        
        return days
    }
   
}
