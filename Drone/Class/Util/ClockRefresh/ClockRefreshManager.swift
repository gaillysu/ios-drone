//
//  ClockRefreshManager.swift
//  Nevo
//
//  Created by leiyuncun on 15/10/6.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class ClockRefreshManager: NSObject {
    private static var __once: () = {
            Static.instance = ClockRefreshManager()
        }()
    fileprivate var refreshObject:[ClockRefreshDelegate] = []

    class var sharedInstance : ClockRefreshManager {
        struct Static {
            static var onceToken : Int = 0
            static var instance : ClockRefreshManager? = nil
        }
        _ = ClockRefreshManager.__once
        return Static.instance!
    }

    override init() {
        super.init()
        /**
        *  Ten seconds to refresh the clock and read the data
        */
        Timer.scheduledTimer(timeInterval: 10, target: self, selector:#selector(ClockRefreshManager.refreshTimerAction(_:)), userInfo: nil, repeats: true);
    }

    func refreshTimerAction(_ timer:Timer){
        for delegate in refreshObject {
            delegate.clockRefreshAction()
        }
    }

    /**
    Set clock the refresh objects

    :param: delegate refresh objects
    */
    func setRefreshDelegate(_ delegate:ClockRefreshDelegate){
        refreshObject.append(delegate)
    }
}

protocol ClockRefreshDelegate {

    /**
    *  Refresh the callback protocol
    */
    func clockRefreshAction()
}
