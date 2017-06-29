//
//  AlarmSectionViewModel.swift
//  Drone
//
//  Created by Karl-John Chow on 19/6/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import Foundation
import UIKit
import RxDataSources

struct AlarmSectionViewModel {
    var header:String
    var items: [Item]
    
    init (header:String, items:[Item]){
        self.header = header
        self.items = items
    }
}

extension AlarmSectionViewModel: AnimatableSectionModelType{
    init(original: AlarmSectionViewModel, items: [AlarmSectionViewModelItem]) {
        self = original
        self.items = items
    }
    
    typealias Item = AlarmSectionViewModelItem
    
    var identity: String {
        return header
    }
}
