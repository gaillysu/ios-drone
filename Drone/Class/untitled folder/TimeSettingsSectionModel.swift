//
//  TimeSettingsSectionModel.swift
//  Drone
//
//  Created by Karl-John Chow on 21/4/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import UIKit
import RxDataSources

struct TimeSettingsSectionModel {

    var header:String
    var items: [item]
    
}

extension TimeSettingsSectionModel: SectionModelType{
    
    typealias item = TimeSettingsSectionItem
    
    init(original: TimeSettingsSectionModel, items: [item]) {
        self.items = items
        self = original
    }
}
