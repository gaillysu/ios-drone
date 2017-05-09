//
//  HotKeySectionModelItem.swift
//  Drone
//
//  Created by Karl-John Chow on 8/5/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import UIKit
import Font_Awesome_Swift
import RxDataSources

struct HotKeySectionModelItem: Hashable{
    var hashValue:Int
    var label: String
    var imageName: String?
    
    init(label:String, imageName:String?) {
        self.label = label
        self.imageName = imageName
        hashValue = label.hashValue
    }
}

extension HotKeySectionModelItem:IdentifiableType, Equatable{
    
    
    
    static func ==(lhs: HotKeySectionModelItem, rhs: HotKeySectionModelItem) -> Bool {
        return lhs.label == rhs.label
    }

    typealias Identity = HotKeySectionModelItem
    
    var identity : Identity { get{
            return self
        }
    }

}
