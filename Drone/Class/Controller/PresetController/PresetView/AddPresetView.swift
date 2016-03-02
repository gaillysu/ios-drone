//
//  AddPresetView.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/3.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class AddPresetView: UIView {
    var mDelegate:ButtonManagerCallBack?

    @IBOutlet weak var presetNumber: UITextField!
    @IBOutlet weak var presetName: UITextField!

    func bulidAddPresetView(navigation:UINavigationItem,delegate:ButtonManagerCallBack){
        mDelegate = delegate
        navigation.title = NSLocalizedString("AddPreset", comment: "")
        self.backgroundColor = AppTheme.hexStringToColor("#f4f2f1")//AppTheme.NEVO_CUSTOM_COLOR(Red: 241.0, Green: 240.0, Blue: 241.0)

        let rightButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: Selector("controllManager:"))
        navigation.rightBarButtonItem = rightButton

        let rightView:UILabel = UILabel(frame: CGRectMake(0,0,50,presetNumber.frame.size.height))
        rightView.text = NSLocalizedString("steps", comment: "")
        rightView.textAlignment = NSTextAlignment.Center
        rightView.font = AppTheme.SYSTEMFONTOFSIZE(mSize: 18)
        rightView.textColor = UIColor.grayColor()
        presetNumber.rightView = rightView
        presetNumber.rightViewMode = UITextFieldViewMode.Always
        presetNumber.textAlignment = NSTextAlignment.Center
        presetNumber.font = AppTheme.SYSTEMFONTOFSIZE(mSize: 18)
        presetNumber.keyboardType = UIKeyboardType.NumberPad
        presetNumber.layer.cornerRadius = 8
        presetNumber.layer.masksToBounds = true
        presetNumber.layer.borderWidth = 1
        presetNumber.layer.borderColor = UIColor.grayColor().CGColor
        presetNumber.backgroundColor = UIColor.whiteColor()

        presetName.placeholder = NSLocalizedString("Preset Name", comment: "")
        presetName.backgroundColor = UIColor.whiteColor()
    }

    func controllManager(sender:AnyObject){
        mDelegate?.controllManager(sender)
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
