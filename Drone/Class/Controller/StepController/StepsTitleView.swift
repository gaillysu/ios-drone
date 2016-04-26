//
//  StepsTitleView.swift
//  Drone
//
//  Created by leiyuncun on 16/4/25.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit

class StepsTitleView: UIView {

    @IBOutlet weak var calendarButton: UIButton!

    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var backButton: UIButton!

    var buttonResultHandler:((result:AnyObject?) -> Void)?

    class func getStepsTitleView(frame:CGRect)->StepsTitleView {
        let nibView:NSArray = NSBundle.mainBundle().loadNibNamed("StepsTitleView", owner: nil, options: nil)
        let view:UIView = nibView.objectAtIndex(0) as! UIView
        view.frame = frame
        return nibView.objectAtIndex(0) as! StepsTitleView
    }

    
    @IBAction func buttonActionManager(sender: AnyObject) {
        if (sender.isEqual(calendarButton)) {
            self.selectedFinishTitleView()
        }
        buttonResultHandler?(result: sender)
    }

    /**
     finish selected calendar ,hiden titleView next button and back button
     */
    func selectedFinishTitleView() {
        calendarButton.selected = (calendarButton.selected ? false:true)
        nextButton.hidden = (nextButton.hidden ? false:true)
        backButton.hidden = (backButton.hidden ? false:true)
    }


    /**
     set titleview text

     - parameter title: title text
     */
    func setCalendarButtonTitle(title:String) {
        calendarButton.titleLabel?.font = UIFont.systemFontOfSize(14)
        calendarButton.setTitle(title, forState: UIControlState.Normal)
        calendarButton.setTitle(title, forState: UIControlState.Selected)
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
