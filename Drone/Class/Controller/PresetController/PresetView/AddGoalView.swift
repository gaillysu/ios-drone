//
//  AddPresetView.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/3.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class AddGoalView: UIView {
    var mDelegate:ButtonManagerCallBack?
    
    @IBOutlet weak var goalNumber: UITextField!
    @IBOutlet weak var goalName: UITextField!
    
    func bulidAddGoalView(navigation:UINavigationItem,delegate:ButtonManagerCallBack){
        mDelegate = delegate
        navigation.title = NSLocalizedString("AddPreset", comment: "")
        self.backgroundColor = AppTheme.hexStringToColor("#f4f2f1")//AppTheme.NEVO_CUSTOM_COLOR(Red: 241.0, Green: 240.0, Blue: 241.0)
        
        let rightButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: Selector("controllManager:"))
        navigation.rightBarButtonItem = rightButton
        
        let rightView:UILabel = UILabel(frame: CGRectMake(0,0,50,goalNumber.frame.size.height))
        rightView.text = NSLocalizedString("steps", comment: "")
        rightView.textAlignment = NSTextAlignment.Center
        rightView.font = AppTheme.SYSTEMFONTOFSIZE(mSize: 18)
        rightView.textColor = UIColor.grayColor()
        goalNumber.rightView = rightView
        goalNumber.rightViewMode = UITextFieldViewMode.Always
        goalNumber.textAlignment = NSTextAlignment.Center
        goalNumber.font = AppTheme.SYSTEMFONTOFSIZE(mSize: 18)
        goalNumber.keyboardType = UIKeyboardType.NumberPad
        goalNumber.layer.cornerRadius = 8
        goalNumber.layer.masksToBounds = true
        goalNumber.layer.borderWidth = 1
        goalNumber.layer.borderColor = UIColor.grayColor().CGColor
        goalNumber.backgroundColor = UIColor.whiteColor()
        
        goalName.placeholder = NSLocalizedString("Preset Name", comment: "")
        goalName.backgroundColor = UIColor.whiteColor()
    }
    
    func controllManager(sender:AnyObject){
        mDelegate?.controllManager(sender)
    }
}