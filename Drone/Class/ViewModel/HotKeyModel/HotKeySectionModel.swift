//
//  HotKeySectionModel.swift
//  Drone
//
//  Created by Karl-John Chow on 8/5/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import UIKit
import RxDataSources

struct HotKeySectionModel {
    var header:String
    var footer:String
    var items: [Item]
}

extension HotKeySectionModel: AnimatableSectionModelType{
    init(original: HotKeySectionModel, items: [HotKeySectionModelItem]) {
        self = original
        self.items = items
    }
    
    typealias Item = HotKeySectionModelItem
    
    var identity: String {
        return header
    }
}
