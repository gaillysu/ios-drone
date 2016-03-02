//
//  ClockRefreshManager.swift
//  Nevo
//
//  Created by leiyuncun on 15/10/6.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class ClockRefreshManager: NSObject {
    private var refreshObject:[ClockRefreshDelegate] = []

    class var sharedInstance : ClockRefreshManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : ClockRefreshManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = ClockRefreshManager()
        }
        return Static.instance!
    }

    override init() {
        super.init()
        /**
        *  Ten seconds to refresh the clock and read the data
        */
        NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector:"refreshTimerAction:", userInfo: nil, repeats: true);
    }

    func refreshTimerAction(timer:NSTimer){
        for delegate in refreshObject {
            delegate.clockRefreshAction()
        }
    }

    /**
    Set clock the refresh objects

    :param: delegate refresh objects
    */
    func setRefreshDelegate(delegate:ClockRefreshDelegate){
        refreshObject.append(delegate)
    }
}

protocol ClockRefreshDelegate {

    /**
    *  Refresh the callback protocol
    */
    func clockRefreshAction()
}
