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
    private static let SEND_LOCAL_MESSAGE_KEY = "ISSENDLOCALMSG"
    private static let WORLDCLOCK_KEY = "DEFAULTS_WORLDCLOCK_KEY"
    private static let WORLDCLOCK_SORT_KEY = "WORLDCLOCK_SORT_KEY"
    private static let HOME_CITY_ID_KEY = "HOME_CITY_ID_KEY"
    private static let SETWEATHER_KEY = "SET_WEATHER_KEY"
    
    private static let TOP_KEY_KEY = "TOP_KEY_KEY"
    private static let COMPASS_KEY = "COMPASS_KEY"
    private static let PAIR_PRESENT_KEY = "PAIR_PRESENT_KEY"
    private static let SYNC_LOCAL_TIME_KEY = "SYNC_LOCAL_TIME_KEY"
    private static let SYNC_ANALOG_TIME_KEY = "SYNC_ANALOG_TIME_KEY"
    
    private static let HOUR_FORMAT_KEY = "HOUR_FORMAT_KEY"
    
    
    
    // MARK: Setup
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
    
    // MARK: Time
    public static var worldClockVersion:Int {
        get{
            return UserDefaults().integer(forKey: WORLDCLOCK_KEY)
        }
        set{
            UserDefaults().set(newValue, forKey: WORLDCLOCK_KEY)
            UserDefaults.standard.synchronize()
        }
    }
    
    public static var homeTimeId:Int {
        get{
            return UserDefaults().integer(forKey: HOME_CITY_ID_KEY)
        }
        set{
            UserDefaults().set(newValue, forKey: HOME_CITY_ID_KEY)
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
    
    public static var syncLocalTime:Bool {
        get{
            return UserDefaults().bool(forKey: SYNC_LOCAL_TIME_KEY)
        }
        set{
            UserDefaults().set(newValue, forKey: SYNC_LOCAL_TIME_KEY)
            UserDefaults.standard.synchronize()
        }
    }
    
    public static var syncWeatherDate:Date {
        get{
            if let sorted = UserDefaults().object(forKey: SETWEATHER_KEY){
                return sorted as! Date
            }
            return Date()
        }
        set{
            UserDefaults().set(newValue, forKey: SETWEATHER_KEY)
        }
    }
    
    public static var syncAnalogTime:Bool {
        get{
            return UserDefaults().bool(forKey: SYNC_ANALOG_TIME_KEY)
        }
        set{
            UserDefaults().set(newValue, forKey: SYNC_ANALOG_TIME_KEY)
            UserDefaults.standard.synchronize()
        }
    }
    
    public static var hourFormat:Int {
        get{
            return UserDefaults().integer(forKey: HOUR_FORMAT_KEY)
        }
        set{
            UserDefaults().set(newValue, forKey: HOUR_FORMAT_KEY)
            UserDefaults.standard.synchronize()
        }
    }
    
    // MARK: Compass
    public static var compassState:Bool {
        get{
            return UserDefaults().bool(forKey: COMPASS_KEY)
        }
        set{
            UserDefaults().set(newValue, forKey: COMPASS_KEY)
            UserDefaults.standard.synchronize()
        }
    }
    
    // MARK: Menu
    public static var presentMenu:Bool {
        get{
            return UserDefaults().bool(forKey: PAIR_PRESENT_KEY)
        }
        set{
            UserDefaults().set(newValue, forKey: PAIR_PRESENT_KEY)
            UserDefaults.standard.synchronize()
        }
    }
 
    // MARK: Menu
    public static var topKeySelection:Int {
        get{
            return UserDefaults().integer(forKey: TOP_KEY_KEY)
        }
        set{
            UserDefaults().set(newValue, forKey: TOP_KEY_KEY)
            UserDefaults.standard.synchronize()
        }
    }
    
    
}
