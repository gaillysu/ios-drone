//
//  DTUserDefaults.swift
//  Drone
//
//  Created by Karl-John Chow on 10/4/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import Foundation

public class DTUserDefaults: NSObject {
    
    private static let SETUP_KEY = "SETUP_KEY"
    private static let SET_RTC_DATE = "SET_RTC"
    private static let SEND_LOCAL_MESSAGE_KEY = "IsSendLocalMsg"
    private static let WORLDCLOCK_KEY = "defaults_worldclock_key"
    private static let WORLDCLOCK_SORT_KEY = "WORLDCLOCK_SORT_KEY"
    private static let SETWEATHER_KEY = "set_weather_key"
    
    public static var setupKey:Bool {
        get{
            return UserDefaults().bool(forKey: SETUP_KEY)
        }
        set{
            UserDefaults().set(newValue, forKey: SETUP_KEY)
            UserDefaults.standard.synchronize()
        }
    }
    
    public static var rtcDate:Date? {
        get{
            return UserDefaults().object(forKey: SET_RTC_DATE) as? Date
        }
        set{
            UserDefaults().set(newValue, forKey: SET_RTC_DATE)
            UserDefaults.standard.synchronize()
        }
    }
    
    public static var sendLocalMessageEnabled:Bool{
        get{
            return UserDefaults().bool(forKey: SEND_LOCAL_MESSAGE_KEY)
        }
        set{
            UserDefaults().set(newValue, forKey: SEND_LOCAL_MESSAGE_KEY)
            UserDefaults.standard.synchronize()
        }
    }
    
    public static var worldClockVersion:Int {
        get{
            return UserDefaults().integer(forKey: WORLDCLOCK_KEY)
        }
        set{
            UserDefaults().set(newValue, forKey: WORLDCLOCK_KEY)
            UserDefaults.standard.synchronize()
        }
    }
    
    public static var selectedCityOrder:[Int]{
        get{
            if let sorted = UserDefaults().array(forKey: WORLDCLOCK_SORT_KEY) as? [Int]{
                return sorted
            }
            return []
        }
        set{
            UserDefaults().set(newValue, forKey: WORLDCLOCK_SORT_KEY)
            UserDefaults.standard.synchronize()
        }
    }
    
    static var syncWeatherDate:Date {
        get{
            if let sorted = UserDefaults().object(forKey: SETWEATHER_KEY){
                return sorted as! Date
            }
            return Date()
        }
        set{
            UserDefaults().set(newValue, forKey: SETWEATHER_KEY)
            UserDefaults.standard.synchronize()
        }
    }
    
}
