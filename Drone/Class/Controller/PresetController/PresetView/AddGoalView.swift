//
//  AddPresetView.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/3.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class AddGoalView: UIView {
    @IBOutlet weak var goalNumber: UITextField!
    @IBOutlet weak var goalName: UITextField!
    
    func bulidAddGoalView(_ navigation:UINavigationItem){

        navigation.title = NSLocalizedString("AddPreset", comment: "")
        self.backgroundColor = AppTheme.hexStringToColor("#f4f2f1")//AppTheme.NEVO_CUSTOM_COLOR(Red: 241.0, Green: 240.0, Blue: 241.0)
        
        let rightButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: Selector("controllManager:"))
        navigation.rightBarButtonItem = rightButton
        
        let rightView:UILabel = UILabel(frame: CGRect(x: 0,y: 0,width: 50,height: goalNumber.frame.size.height))
        rightView.text = NSLocalizedString("steps", comment: "")
        rightView.textAlignment = NSTextAlignment.center
        rightView.font = AppTheme.SYSTEMFONTOFSIZE(mSize: 18)
        rightView.textColor = UIColor.gray
        goalNumber.rightView = rightView
        goalNumber.rightViewMode = UITextFieldViewMode.always
        goalNumber.textAlignment = NSTextAlignment.center
        goalNumber.font = AppTheme.SYSTEMFONTOFSIZE(mSize: 18)
        goalNumber.keyboardType = UIKeyboardType.numberPad
        goalNumber.layer.cornerRadius = 8
        goalNumber.layer.masksToBounds = true
        goalNumber.layer.borderWidth = 1
        goalNumber.layer.borderColor = UIColor.gray.cgColor
        goalNumber.backgroundColor = UIColor.white
        
        goalName.placeholder = NSLocalizedString("Preset Name", comment: "")
        goalName.backgroundColor = UIColor.white
    }
     
}
