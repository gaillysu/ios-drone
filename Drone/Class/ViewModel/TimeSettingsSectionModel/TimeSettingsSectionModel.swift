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
    var footer:String
    var items: [Item]
}

extension TimeSettingsSectionModel: SectionModelType{
    init(original: TimeSettingsSectionModel, items: [TimeSettingsSectionItem]) {
        self = original
        self.items = items
    }

    typealias Item = TimeSettingsSectionItem
    
}
