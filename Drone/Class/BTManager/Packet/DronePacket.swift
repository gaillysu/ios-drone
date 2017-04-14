import Foundation

class DronePacket {
    fileprivate var mPackets:[Data]=[]
    fileprivate var mHeader:UInt8 = 0
    let endFlag:UInt8 = 0xFF
    
    struct DailyHistory
    {
        var TotalSteps:Int = 0;
        //add new from v1.2.2
        //unit:cm->meter
        var TotalDist:Int = 0;
        var HourlyDist:[Int] = [];
        //unit: cal->kcal
        var TotalCalories:Int = 0;
        var HourlyCalories:[Int] = [0];
        var InactivityTime:Int = 0;
        var TotalInZoneTime:Int = 0;
        var TotalOutZoneTime:Int = 0;
        //unit: minute
        var TotalSleepTime:Int = 0;
        var HourlySleepTime:[Int] = [];
        var TotalWakeTime:Int = 0;
        var HourlyWakeTime:[Int] = [];
        var TotalLightTime:Int = 0;
        var HourlyLightTime:[Int] = [];
        var TotalDeepTime:Int = 0;
        var HourlyDeepTime:[Int] = [];
        //end add new
        var Date:Foundation.Date;
        init( date:Foundation.Date)
        {
           Date = date
        }
    }
    
    init(packets:[Data])
    {
        if(packets.count >= 2)
        {
        mPackets = packets
        mHeader = Constants.NSData2Bytes(mPackets[0])[1]
        }
    }
    
    func getHeader() ->UInt8
    {
        return mHeader
    }
    func getPackets() ->[Data]
    {
        return mPackets
    }

    //only two types packets: 2/78 count
    func isVaildPacket() ->Bool
    {
        if(mPackets.count == 2)
        {
           return true
        }
        if(mPackets.count == 78)
        {
            for i:Int in 0  ..< mPackets.count 
            {
                if UInt8(i) != Constants.NSData2Bytes(mPackets[i])[0] && i != mPackets.count - 1
                {
                    return false
                }
                if mHeader != Constants.NSData2Bytes(mPackets[i])[1]
                {
                    return false
                }
            }
            return true
        }
        return false
    }
}
