//
//  Date+Extension.swift
//  Drone
//
//  Created by Cloud on 2017/7/06.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import Foundation
import Timepiece

extension Date {
    fileprivate struct AssociatedKeys {
        static var TimeZone = "timepiece_TimeZone"
    }

    var beginningOfYear: Date? {
        return self.changed(month: 1, day: 1, hour: 0, minute: 0, second: 0)
    }
    
    var endOfYear: Date {
        return self.changed(month: 12, day: 31, hour: 23, minute: 59, second: 59)!
    }
    
    var beginningOfMonth: Date {
        return self.changed(day: 1, hour: 0, minute: 0, second: 0)!
    }
    
    var beginningOfWeek: Date {
        let daysDiff = (7 + (weekday - Calendar.current.firstWeekday)) % 7
        return (beginningOfDay - daysDiff.days)!
    }
    
    var endOfWeek: Date {
        let daysDiff = (7 + ((Calendar.current.firstWeekday - 1) - weekday)) % 7
        return (endOfDay + daysDiff.days)!
    }
    
    var beginningOfDay: Date {
        return self.changed(hour: 0, minute: 0, second: 0)!
    }
    var endOfDay: Date {
        return self.changed(hour: 23, minute: 59, second: 59)!
    }
    
    var beginningOfHour: Date {
        return self.changed(minute: 0, second: 0)!
    }
    var endOfHour: Date {
        return self.changed(minute: 59, second: 59)!
    }
    
    var beginningOfMinute: Date {
        return self.changed(second: 0)!
    }
    
    var endOfMinute: Date {
        return self.changed(second: 59)!
    }

    var oldTimeZone: NSTimeZone {
        return objc_getAssociatedObject(self, &AssociatedKeys.TimeZone) as? NSTimeZone ?? Calendar.current.timeZone as NSTimeZone
    }

    // MARK: - Format dates
    
    func stringFromFormat(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func stringFromFormat(_ format: String, locale: Locale) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    // MARK: - Localized time
        
    func localizedTime() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    func localizedTime(_ locale: Locale) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}
