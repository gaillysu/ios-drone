//
//  WorldClockHeader.swift
//  Drone
//
//  Created by Karl-John on 25/4/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation

class WorldClockHeader: UIView{

    var actionHandler:((result:AnyObject?) -> Void)?

    class func getWorldClockHeader(frame:CGRect)->WorldClockHeader {
        let nibView:NSArray = NSBundle.mainBundle().loadNibNamed("WorldClockHeader", owner: nil, options: nil)
        let view:UIView = nibView.objectAtIndex(0) as! UIView
        view.frame = frame
        return nibView.objectAtIndex(0) as! WorldClockHeader
    }

    @IBAction func buttonActionManager(sender: AnyObject) {
        actionHandler?(result: sender)
    }
}