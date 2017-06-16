//
//  Bundle+Extension.swift
//  Drone
//
//  Created by Cloud on 2017/6/14.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit

extension Bundle {
    static var googleMapKey:String? {
        get{
            let mainDictionary = self.main.infoDictionary
            return mainDictionary?["GoogleMapKey"] as? String
        }
    }
}
