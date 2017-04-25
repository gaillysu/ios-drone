//
//  DateFormatter+Extension.swift
//  Drone
//
//  Created by Cloud on 2017/4/25.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import Foundation

extension DateFormatter {

    static func localCityName() -> String {
        let timeZoneNameData = DateFormatter().timeZone.identifier.characters.split{$0 == "/"}.map(String.init)
        if timeZoneNameData.count >= 2 {
            return timeZoneNameData[1].replacingOccurrences(of: "_", with: " ")
        }
        return String(format: "%@", timeZoneNameData)
    }
}
