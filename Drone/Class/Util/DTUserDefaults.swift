//
//  DTUserDefaults.swift
//  Drone
//
//  Created by Karl-John Chow on 10/4/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import Foundation

let syncWeatherInterval:Double = 300 //seconds
public class DTUserDefaults: NSObject {
    
    private static let SETUP_KEY = "SETUP_KEY"
    private static let SET_RTC_DATE = "SET_RTC"
    private static let COUNT_DOWN_TIME = "COUNT_DOWN_TIME"
    private static let SEND_LOCAL_MESSAGE_KEY = "ISSENDLOCALMSG"
    private static let WORLDCLOCK_KEY = "DEFAULTS_WORLDCLOCK_KEY"
    private static let WORLDCLOCK_SORT_KEY = "WORLDCLOCK_SORT_KEY"
    private static let HOME_CITY_ID_KEY = "HOME_CITY_ID_KEY"
    private static let LAST_SYNC_WEATHER_DATE = "LAST_SYNC_WEATHER_DATE"
    private static let LAST_SYNC_WEATHER_CITY = "LAST_SYNC_WEATHER_CITY"
    
    private static let TOP_KEY_KEY = "TOP_KEY_KEY"
    private static let COMPASS_KEY = "COMPASS_KEY"
    private static let PAIR_PRESENT_KEY = "PAIR_PRESENT_KEY"
    private static let SYNC_LOCAL_TIME_KEY = "SYNC_LOCAL_TIME_KEY"
    private static let SYNC_ANALOG_TIME_KEY = "SYNC_ANALOG_TIME_KEY"
    
    private static let HOUR_FORMAT_KEY = "HOUR_FORMAT_KEY"
    private static let LANGUAGE_KEY = "AppleLanguages"
    private static let ENABLED_ALL_NOTIFICATIONS_KEY = "ENABLED_ALL_NOTIFICATIONS_KEY"
    private static let LAST_VISITED_CITIES_KEY = "LAST_VISITED_CITIES_KEY"
    
    
    // MARK: Setup
    public static var setupKey:Bool {
        get{
            return UserDefaults().bool(forKey: SETUP_KEY)
        }
        set{
            UserDefaults().set(newValue, forKey: SETUP_KEY)
        }
    }
    
    public static var rtcDate:Date? {
        get{
            return UserDefaults().object(forKey: SET_RTC_DATE) as? Date
        }
        set{
            UserDefaults().set(newValue, forKey: SET_RTC_DATE)
        }
    }
    
    public static var sendLocalMessageEnabled:Bool{
        get{
            return UserDefaults().bool(forKey: SEND_LOCAL_MESSAGE_KEY)
        }
        set{
            UserDefaults().set(newValue, forKey: SEND_LOCAL_MESSAGE_KEY)
        }
    }
    
    // MARK: Time
    public static var worldClockVersion:Int {
        get{
            return UserDefaults().integer(forKey: WORLDCLOCK_KEY)
        }
        set{
            UserDefaults().set(newValue, forKey: WORLDCLOCK_KEY)
        }
    }
    
    public static var homeTimeId:Int {
        get{
            return UserDefaults().integer(forKey: HOME_CITY_ID_KEY)
        }
        set{
            UserDefaults().set(newValue, forKey: HOME_CITY_ID_KEY)
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
        }
    }
    
    public static var syncLocalTime:Bool {
        get{
            return UserDefaults().bool(forKey: SYNC_LOCAL_TIME_KEY)
        }
        set{
            UserDefaults().set(newValue, forKey: SYNC_LOCAL_TIME_KEY)
        }
    }
    
    
    public static var countdownTime:Int {
        get{
            let val = UserDefaults().integer(forKey: COUNT_DOWN_TIME)
            return val == 0 ? 1 : val
        }
        set{
            UserDefaults().set(newValue, forKey: COUNT_DOWN_TIME)
        }
    }
    
    // MARK: Weather
    public static var lastSyncedWeatherDate:Date {
        get{
            if let object = UserDefaults().object(forKey: LAST_SYNC_WEATHER_DATE), let date = object as? Date{
                return date
            }
            let lastDate = Date(timeIntervalSince1970: Date().timeIntervalSince1970-syncWeatherInterval)
            UserDefaults().set(lastDate, forKey: LAST_SYNC_WEATHER_DATE)
            return lastDate
        }
        set{
            UserDefaults().set(newValue, forKey: LAST_SYNC_WEATHER_DATE)
        }
    }
    
    public static var lastSyncedWeatherCity:String? {
        get{
            return UserDefaults().string(forKey: LAST_SYNC_WEATHER_CITY)
        }
        set{
            UserDefaults().set(newValue, forKey: LAST_SYNC_WEATHER_CITY)
        }
    }
    
    public static var syncAnalogTime:Bool {
        get{
            return UserDefaults().bool(forKey: SYNC_ANALOG_TIME_KEY)
        }
        set{
            UserDefaults().set(newValue, forKey: SYNC_ANALOG_TIME_KEY)
        }
    }
    
    public static var hourFormat:Int {
        get{
            return UserDefaults().integer(forKey: HOUR_FORMAT_KEY)
        }
        set{
            UserDefaults().set(newValue, forKey: HOUR_FORMAT_KEY)
        }
    }
    
    // MARK: Compass
    public static var compassState:Bool {
        get{
            return UserDefaults().bool(forKey: COMPASS_KEY)
        }
        set{
            UserDefaults().set(newValue, forKey: COMPASS_KEY)
        }
    }
    
    // MARK: Menu
    public static var presentMenu:Bool {
        get{
            return UserDefaults().bool(forKey: PAIR_PRESENT_KEY)
        }
        set{
            UserDefaults().set(newValue, forKey: PAIR_PRESENT_KEY)
        }
    }
    
    // MARK: Menu
    public static var topKeySelection:Int {
        get{
            return UserDefaults().integer(forKey: TOP_KEY_KEY)
        }
        set{
            UserDefaults().set(newValue, forKey: TOP_KEY_KEY)
        }
    }
    
    // MARK: Menu
    public static var enabledAllNotifications:Bool {
        get{
            return UserDefaults().bool(forKey: ENABLED_ALL_NOTIFICATIONS_KEY)
        }
        set{
            UserDefaults().set(newValue, forKey: ENABLED_ALL_NOTIFICATIONS_KEY)
        }
    }
    
    public static var localLanguage:String {
        get{
            if let languages:[String] = UserDefaults.standard.object(forKey: LANGUAGE_KEY) as? [String]{
                if let value = languages.first {
                    return value
                }
            }
            return ""
        }
    }
    
    public static var lastVisitedCities:[String] {
        get{
            if let cities:[String] = UserDefaults.standard.object(forKey: LAST_VISITED_CITIES_KEY) as? [String]{
                return cities
            }
            return []
        }
        set { UserDefaults().set(newValue, forKey: LAST_VISITED_CITIES_KEY) }
    }
    
    
    public static func saveLog(message:String, key:String, reset:Bool = false){
        
        let defaults = UserDefaults.standard
        if let stringArray = defaults.stringArray(forKey: key){
            var newArray = stringArray
            if newArray.count > 20 {
                newArray.remove(at: 0)
            }else if reset {
                newArray.removeAll()
            }
            newArray.append("\(Date().iso8601) -> \(message)")
            defaults.set(newArray, forKey: key)
        } else {
            defaults.set(["\(Date().iso8601) ->", message], forKey: key)
        }
    }
    
    public static func getStringArrayLog(key:String) -> [String]{
        let defaults = UserDefaults.standard
        if let array = defaults.array(forKey: key), let stringArray = array as? [String]{
            return stringArray
        }
        return []
    }
}
