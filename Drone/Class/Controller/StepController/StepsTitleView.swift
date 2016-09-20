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

    var buttonResultHandler:((_ result:AnyObject?) -> Void)?

    class func getStepsTitleView(_ frame:CGRect)->StepsTitleView {
        let nibView:[Any?] = Bundle.main.loadNibNamed("StepsTitleView", owner: nil, options: nil)!
        let view:UIView = nibView[0] as! UIView
        view.frame = frame
        return nibView[0] as! StepsTitleView
    }

    
    @IBAction func buttonActionManager(_ sender: AnyObject) {
        if (sender.isEqual(calendarButton)) {
            self.selectedFinishTitleView()
        }
        buttonResultHandler?(sender)
    }

    /**
     finish selected calendar ,hiden titleView next button and back button
     */
    func selectedFinishTitleView() {
        calendarButton.isSelected = (calendarButton.isSelected ? false:true)
        nextButton.isHidden = (nextButton.isHidden ? false:true)
        backButton.isHidden = (backButton.isHidden ? false:true)
    }


    /**
     set titleview text

     - parameter title: title text
     */
    func setCalendarButtonTitle(_ title:String) {
        calendarButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        calendarButton.setTitle(title, for: UIControlState())
        calendarButton.setTitle(title, for: UIControlState.selected)
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
