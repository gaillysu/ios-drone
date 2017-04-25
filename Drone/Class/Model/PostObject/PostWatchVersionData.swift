//
//  PostWatchVersionData.swift
//  Drone
//
//  Created by Cloud on 2017/4/19.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit

class PostWatchVersionData: NSObject {
    var watchVersion:String?
    var versionType:String?
    
    init(version:String,type:String) {
        super.init()
        watchVersion = version
        versionType = type
    }
}
