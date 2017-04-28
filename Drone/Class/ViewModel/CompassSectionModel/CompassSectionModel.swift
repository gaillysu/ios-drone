//
//  TimeSettingsSectionModel.swift
//  Drone
//
//  Created by Karl-John Chow on 21/4/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import UIKit
import RxDataSources

struct CompassSectionModel {
    var header:String
    var footer:String
    var items: [Item]
}

extension CompassSectionModel: SectionModelType{
    init(original: CompassSectionModel, items: [CompassSectionModelItem]) {
        self = original
        self.items = items
    }

    typealias Item = CompassSectionModelItem
    
}
