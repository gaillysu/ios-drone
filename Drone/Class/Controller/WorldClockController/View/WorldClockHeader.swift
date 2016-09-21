//
//  WorldClockHeader.swift
//  Drone
//
//  Created by Karl-John on 25/4/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation

class WorldClockHeader: UIView{

    var actionHandler:((_ result:AnyObject?) -> Void)?

    @IBOutlet weak var dateLabel: UILabel!
    class func getWorldClockHeader(_ frame:CGRect)->WorldClockHeader {
        let nibView:[Any?] = Bundle.main.loadNibNamed("WorldClockHeader", owner: nil, options: nil)!
        let view:UIView = nibView[0] as! UIView
        view.frame = frame
        return nibView[0] as! WorldClockHeader
    }
}
