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
        hashValue = alarm.label.hashValue
    }
}

extension AlarmSectionViewModelItem:IdentifiableType, Equatable{
    
    static func ==(lhs: AlarmSectionViewModelItem, rhs: AlarmSectionViewModelItem) -> Bool {
        return lhs.alarm.label == rhs.alarm.label
    }
    
    typealias Identity = AlarmSectionViewModelItem
    
    var identity : Identity { get{
        return self
        }
    }
    
}
