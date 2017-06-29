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
    
    var key:String
    var hashValue:Int
    
    init(key:String) {
        self.key = key
        hashValue = key.hashValue
    }
}

extension AlarmSectionViewModelItem:IdentifiableType, Equatable{
    
    static func ==(lhs: AlarmSectionViewModelItem, rhs: AlarmSectionViewModelItem) -> Bool {
        return lhs.key == rhs.key
    }
    
    typealias Identity = String
    
    var identity : String { get{
        return self.key
        }
    }
    
}
