//
//  StepsTitleView.swift
//  Drone
//
//  Created by leiyuncun on 16/4/25.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit

class StepsTitleView: UIView {


    var buttonResultHandler:((result:AnyObject?) -> Void)?

    class func getStepsTitleView(frame:CGRect)->StepsTitleView {
        let nibView:NSArray = NSBundle.mainBundle().loadNibNamed("StepsTitleView", owner: nil, options: nil)
        let view:UIView = nibView.objectAtIndex(0) as! UIView
        view.frame = frame
        return nibView.objectAtIndex(0) as! StepsTitleView
    }

    
    @IBAction func buttonActionManager(sender: AnyObject) {
        buttonResultHandler?(result: sender)
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
