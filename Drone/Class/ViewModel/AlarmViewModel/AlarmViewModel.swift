//
//  AlarmViewModel.swift
//  Drone
//
//  Created by Karl-John Chow on 19/6/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import Foundation
import RxSwift

class AlarmViewModel{
    
    var disposeBag = DisposeBag()
    
    let data:Variable<[AlarmSectionViewModel]>
    
    init() {
        data = Variable([])

    }
}
