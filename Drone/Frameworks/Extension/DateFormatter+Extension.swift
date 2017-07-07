//
//  DateFormatter+Extension.swift
//  Drone
//
//  Created by Cloud on 2017/4/25.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import Foundation

extension DateFormatter {

    func localCityName() -> String {
        let timeZoneNameData = DateFormatter().timeZone.identifier.characters.split{$0 == "/"}.map(String.init)
        if timeZoneNameData.count >= 2 {
            return timeZoneNameData[1].replacingOccurrences(of: "_", with: " ")
        }
        return String(format: "%@", timeZoneNameData)
    }
    
    // Returns 28 April 2017
    func normalDateString () -> String{
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMMM yyyy"
            return formatter.string(from: Date())
    }
}

extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
}
extension Date {
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}

extension String {
    var dateFromISO8601: Date? {
        return Formatter.iso8601.date(from: self)   // "Mar 22, 2017, 10:22 AM"
    }
}
