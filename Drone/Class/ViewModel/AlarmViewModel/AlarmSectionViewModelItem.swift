//
//  AlarmSectionViewModelItem.swift
//  Drone
//
//  Created by Karl-John Chow on 19/6/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import Foundation
import Font_Awesome_Swift
import RxDataSources

struct AlarmSectionViewModelItem: Hashable{
    
    var alarm:MEDAlarm
    var hashValue:Int
    
    init(alarm:MEDAlarm) {
        self.alarm = alarm
        hashValue = alarm.key.hashValue
    }
}

extension AlarmSectionViewModelItem:IdentifiableType, Equatable{
    
    static func ==(lhs: AlarmSectionViewModelItem, rhs: AlarmSectionViewModelItem) -> Bool {
        return lhs.alarm.key == rhs.alarm.key
    }
    
    typealias Identity = String
    
    var identity : String { get{
        return self.alarm.key
        }
    }
    
}
