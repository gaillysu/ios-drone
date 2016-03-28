//
//  ProfileController.swift
//  Nevo
//
//  Created by leiyuncun on 16/3/2.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import TextFieldEffects
import SMSegmentView


class ProfileViewController: BaseViewController {

    @IBOutlet weak var ageTextField: AkiraTextField!
    @IBOutlet weak var lengthTextField: AkiraTextField!
    @IBOutlet weak var firstNameTextField: AkiraTextField!
    @IBOutlet weak var lastNameTextField: AkiraTextField!
    @IBOutlet weak var weightTextField: AkiraTextField!
    @IBOutlet weak var stridelengthTextField: AkiraTextField!
    @IBOutlet weak var sexSegment: UISegmentedControl!
    @IBOutlet weak var metricsSegment: UISegmentedControl!

    init() {
        super.init(nibName: "ProfileViewController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let segmentProperties = ["OnSelectionBackgroundColour": UIColor.whiteColor(),"OffSelectionBackgroundColour": AppTheme.BASE_COLOR(),"OnSelectionTextColour": AppTheme.BASE_COLOR(),"OffSelectionTextColour": UIColor.whiteColor()]
    }

    @IBAction func saveButtonAction(sender: AnyObject) {
        for value:AkiraTextField in [weightTextField,lengthTextField,stridelengthTextField] {
            if(value.text!.isEmpty){
                let alert:UIAlertView = UIAlertView(title: value.placeholder!+" is nil", message: nil, delegate: nil, cancelButtonTitle: "Cancel")
                alert.show()
                return
            }
        }

        let weight:Int = Int(weightTextField.text!)!
        let height:Int = Int(lengthTextField.text!)!
        let gender:Bool = !Bool(sexSegment.selectedSegmentIndex)
        let stridelength:Int = Int(stridelengthTextField.text!)!
        AppDelegate.getAppDelegate().sendRequest(SetUserProfileRequest(weight: weight, height: height, gender: Int(gender), stridelength: stridelength))
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        ageTextField.resignFirstResponder()
        lengthTextField.resignFirstResponder()
        firstNameTextField.resignFirstResponder()
        lastNameTextField.resignFirstResponder()
        weightTextField.resignFirstResponder()
        stridelengthTextField.resignFirstResponder()
    }
}