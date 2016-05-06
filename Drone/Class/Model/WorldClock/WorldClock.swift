//
//  WorldClock.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/31.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class WorldClock: NSObject {
    private var worldTimer:NSTimeInterval?
    private var timeZone:NSTimeZone?
    private var worldName:String?

    init(worldtimer: NSTimeInterval,timezone:NSTimeZone,name:String) {
        super.init()
        worldTimer = worldtimer
        timeZone = timezone
        worldName = name
    }

    func getWorldTimer()->NSTimeInterval {
        return worldTimer!
    }

    func getTimeZone() ->NSTimeZone {
        return timeZone!
    }

    func getWorldName() ->String {
        return worldName!
    }
}
