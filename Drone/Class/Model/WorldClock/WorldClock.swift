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
    private var timerZone:NSTimeZone?
    private var worldName:String?

    init(worldtimer: NSTimeInterval,timerzone:NSTimeZone,name:String) {
        super.init()
        worldTimer = worldtimer
        timerZone = timerzone
        worldName = name
    }

    func getWorldTimer()->NSTimeInterval {
        return worldTimer!
    }

    func getTimerZone() ->NSTimeZone {
        return timerZone!
    }

    func getWorldName() ->String {
        return worldName!
    }
}
