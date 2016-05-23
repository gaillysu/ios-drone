//
//  ProfileController.swift
//  Nevo
//
//  Created by leiyuncun on 16/3/2.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import AutocompleteField
import SMSegmentView
import UIColor_Hex_Swift
import YYKeyboardManager
import BRYXBanner
import SwiftyJSON
import MRProgress

private let DATEPICKER_TAG:Int = 1280
private let PICKERVIEW_TAG:Int = 1380

class ProfileSetupViewController: BaseViewController,SMSegmentViewDelegate,YYKeyboardObserver {

    @IBOutlet weak var backB: UIButton!
    @IBOutlet weak var nextB: UIButton!
    @IBOutlet weak var textfiledBG: UIView!
    @IBOutlet weak var ageTextField: AutocompleteField!
    @IBOutlet weak var lengthTextField: AutocompleteField!
    @IBOutlet weak var weightTextField: AutocompleteField!
    @IBOutlet weak var metricsSegment: UIView!

    @IBOutlet weak var lastNameTextField: AutocompleteField!
    @IBOutlet weak var firstNameTextField: AutocompleteField!

    var segmentView:SMSegmentView?
    private var nameDictionary:Dictionary<String,AnyObject> = ["first_name":"DroneUser","last_name":"User"]
    var account:Dictionary<String,AnyObject> = ["email":"","password":""]

    private var selectedTextField: AutocompleteField?
    private var lengthArray:[Int] = []
    private var weightArray:[Int] = []
    private var weightFloatArray:[Int] = []
    private var selectedRow:Int = 0
    private var selectedRow2:Int = 0

    init() {
        super.init(nibName: "ProfileSetupViewController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        textfiledBG.layer.borderColor = UIColor(rgba: "#6F7179").CGColor
        YYKeyboardManager.defaultManager().addObserver(self)
        //Init pickerView the data
        for index:Int in 150...250 {
            lengthArray.append(index)
        }

        for index:Int in 35...150 {
            weightArray.append(index)
        }

        for index:Int in 0...9 {
            weightFloatArray.append(index)
        }
    }

    override func viewDidLayoutSubviews() {
        if(segmentView == nil) {
            let segmentProperties = ["OnSelectionBackgroundColour": UIColor.getBaseColor(),"OffSelectionBackgroundColour": UIColor.whiteColor(),"OnSelectionTextColour": UIColor.whiteColor(),"OffSelectionTextColour": UIColor(rgba: "#95989a")]

            let segmentFrame = CGRect(x: 0, y: 0, width: metricsSegment.frame.size.width, height: metricsSegment.frame.size.height)
            segmentView = SMSegmentView(frame: segmentFrame, separatorColour: UIColor(white: 0.95, alpha: 0.3), separatorWidth: 1.0, segmentProperties: segmentProperties)
            segmentView!.delegate = self
            segmentView!.layer.borderColor = UIColor(white: 0.85, alpha: 1.0).CGColor
            segmentView!.layer.borderWidth = 1.0

            // Add segments
            segmentView!.addSegmentWithTitle("Male", onSelectionImage: nil, offSelectionImage: nil)
            segmentView!.addSegmentWithTitle("Female", onSelectionImage: nil, offSelectionImage: nil)
            segmentView?.selectSegmentAtIndex(0)
            metricsSegment.addSubview(segmentView!)
        }
    }

    @IBAction func buttonActionManager(sender: AnyObject) {
        if (backB.isEqual(sender)) {
            self.navigationController?.popViewControllerAnimated(true)
        }

        if (nextB.isEqual(sender)) {
            registerRequest()
        }
    }

    // MARK: - YYKeyboardObserver
    func keyboardChangedWithTransition(transition: YYKeyboardTransition) {
        UIView.animateWithDuration(transition.animationDuration, delay: 0, options: transition.animationOption, animations: {
            let kbFrame:CGRect = YYKeyboardManager.defaultManager().convertRect(transition.toFrame, toView: self.view)
            let textFrame:CGRect = self.selectedTextField!.frame
            let bgview:CGRect = self.textfiledBG.frame
            if((bgview.origin.y+textFrame.origin.y+textFrame.size.height)>kbFrame.origin.y) {
                self.view.frame = CGRectMake(0, -((bgview.origin.y+textFrame.origin.y+textFrame.size.height)-kbFrame.origin.y), UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
                
            }else{
                self.view.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
            }
            
            }) { (finished) in

        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        ageTextField.resignFirstResponder()
        lengthTextField.resignFirstResponder()
        weightTextField.resignFirstResponder()
        lastNameTextField.resignFirstResponder()
        firstNameTextField.resignFirstResponder()
        self.removeDatePickerView()
        self.removePickerView()
    }

    // MARK: - SMSegmentViewDelegate
    func segmentView(segmentView: SMBasicSegmentView, didSelectSegmentAtIndex index: Int) {
        debugPrint("Select segment at index: \(index)")
    }

    func registerRequest() {
        if(AppTheme.isNull(ageTextField!.text!) || AppTheme.isEmail(lengthTextField!.text!) || AppTheme.isEmail(weightTextField!.text!) || AppTheme.isNull(firstNameTextField.text!) || AppTheme.isNull(lastNameTextField.text!)) {
            let banner = Banner(title: NSLocalizedString("One of the fields are empty.", comment: ""), subtitle: nil, image: nil, backgroundColor:UIColor.redColor())
            banner.dismissesOnTap = true
            banner.show(duration: 0.6)
            return
        }

        let email:String = account["email"] as! String
        let password:String = account["password"] as! String

        let view = MRProgressOverlayView.showOverlayAddedTo(self.navigationController!.view, title: "Please wait...", mode: MRProgressOverlayViewMode.Indeterminate, animated: true)
        view.setTintColor(UIColor.getBaseColor())
        
        //timeout
        let timeout:NSTimer = NSTimer.after(90.seconds, {
            MRProgressOverlayView.dismissAllOverlaysForView(self.navigationController!.view, animated: true)
        })
        
        
        let sex:Int = self.segmentView?.indexOfSelectedSegment == 0 ? 1 : 0
        HttpPostRequest.postRequest("http://drone.karljohnchow.com/user/create", data: ["user":["first_name":self.firstNameTextField.text!,"last_name":self.lastNameTextField.text!,"email":email,"password":password,"birthday":ageTextField!.text!,"length":lengthTextField!.text!, "weight":self.weightTextField.text!, "sex":sex]]) { (result) in
            
            timeout.invalidate()
            
            MRProgressOverlayView.dismissAllOverlaysForView(self.navigationController!.view, animated: true)
            
            let json = JSON(result)
            let message = json["message"].stringValue
            let status = json["status"].intValue
            let user:[String : JSON] = json["user"].dictionaryValue

            let banner = Banner(title: NSLocalizedString(message, comment: ""), subtitle: nil, image: nil, backgroundColor:UIColor.redColor())
            banner.dismissesOnTap = true
            banner.show(duration: 1.2)
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "y-M-d h:m:s.000000"
            let birthdayJSON = user["birthday"]
            let birthdayBeforeParsed = birthdayJSON!["date"].stringValue

            let birthdayDate = dateFormatter.dateFromString(birthdayBeforeParsed)
            dateFormatter.dateFormat = "y-M-d"
            let birthday = dateFormatter.stringFromDate(birthdayDate!)
            let sex = user["sex"]!.intValue == 1 ? true : false;
            if(status > 0 && UserProfile.getAll().count == 0) {
                let userprofile:UserProfile = UserProfile(keyDict: ["first_name":user["first_name"]!.stringValue,"last_name":user["last_name"]!.stringValue,"length":user["length"]!.intValue,"email":user["email"]!.stringValue,"sex": sex, "weight":(user["weight"]?.floatValue)!, "birthday":birthday])
                userprofile.add({ (id, completion) in
                })
                let device:WhichDeviceViewController = WhichDeviceViewController(toMenu: false)
                self.navigationController?.pushViewController(device, animated: true)
            }
        }
    }
}

extension ProfileSetupViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {

    }

    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        if(textField.isEqual(ageTextField)) {
            textField.resignFirstResponder()
        }
        return true
    }

    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        selectedTextField = textField as? AutocompleteField

        if(textField.isEqual(ageTextField)) {
            lengthTextField.resignFirstResponder()
            weightTextField.resignFirstResponder()
            lastNameTextField.resignFirstResponder()
            firstNameTextField.resignFirstResponder()
            self.selectedBirthday()
            return false
        }else if (textField.isEqual(lengthTextField) || textField.isEqual(weightTextField)) {
            weightTextField.resignFirstResponder()
            lastNameTextField.resignFirstResponder()
            firstNameTextField.resignFirstResponder()
            /**
             *  remove date pickerview
             */
            self.removeDatePickerView()

            /**
             *  create selected pickerview
             */
            self.selectedLength()

            /**
             *  if not null reloadAll pickerview
             */
            self.getPickerView()?.reloadAllComponents()
            return false
        }else if(textField.isEqual(firstNameTextField) || textField.isEqual(lastNameTextField)){
            self.removeDatePickerView()
            self.removePickerView()
            
        } else {
            /**
             Need to pop-up keyboard to delete all the picker control
             */
            self.removeDatePickerView()
            self.removePickerView()
        }
        return true
    }

    func selectedBirthday() {
        var datePicker:UIDatePicker?
        let picker = self.view.viewWithTag(DATEPICKER_TAG)
        if(picker == nil) {
            datePicker = UIDatePicker(frame: CGRectMake(0,UIScreen.mainScreen().bounds.size.height,UIScreen.mainScreen().bounds.size.width,200))
            datePicker?.datePickerMode = UIDatePickerMode.Date
            datePicker?.backgroundColor = UIColor.whiteColor()
            datePicker?.tag = DATEPICKER_TAG
            self.view.addSubview(datePicker!)
            datePicker?.addTarget(self, action: #selector(ProfileSetupViewController.selectedDateAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        }else{
            datePicker = picker as? UIDatePicker
        }

        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
            datePicker?.frame = CGRectMake(0,datePicker?.frame.origin.y>=UIScreen.mainScreen().bounds.size.height ? (UIScreen.mainScreen().bounds.size.height-200):(UIScreen.mainScreen().bounds.size.height),UIScreen.mainScreen().bounds.size.width,200)
            }) { (finish) in
                if(datePicker?.frame.origin.y>UIScreen.mainScreen().bounds.size.height) {
                    datePicker?.removeFromSuperview()
                }
        }
    }

    func removeDatePickerView() {
        var datePicker:UIDatePicker?
        let picker = self.view.viewWithTag(DATEPICKER_TAG)
        if(picker != nil) {
            datePicker = picker as? UIDatePicker
            datePicker?.removeFromSuperview()
        }
    }

    func selectedDateAction(date:UIDatePicker) {
        NSLog("date:\(date.date)")
        ageTextField.text = self.dateFormattedStringWithFormat("yyyy-MM-dd", fromDate: date.date)
    }

    func dateFormattedStringWithFormat(format: String, fromDate date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = format
        return formatter.stringFromDate(date)
    }
}

// MARK: - UIPickerView
extension ProfileSetupViewController:UIPickerViewDelegate,UIPickerViewDataSource {

    func selectedLength() {
        var picker:UIPickerView?
        let pickerView = self.view.viewWithTag(PICKERVIEW_TAG)
        if (pickerView == nil) {
            picker = UIPickerView(frame: CGRectMake(0,UIScreen.mainScreen().bounds.size.height,UIScreen.mainScreen().bounds.size.width,200))
            picker?.backgroundColor = UIColor.whiteColor()
            picker?.tag = PICKERVIEW_TAG
            picker?.delegate = self
            self.view.addSubview(picker!)
        }else{
            picker = pickerView as? UIPickerView
        }

        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
            picker?.frame = CGRectMake(0,UIScreen.mainScreen().bounds.size.height-200,UIScreen.mainScreen().bounds.size.width,200)
        }) { (finish) in
            if(picker?.frame.origin.y>UIScreen.mainScreen().bounds.size.height) {
                picker?.removeFromSuperview()
            }
        }
    }

    func removePickerView() {
        var picker:UIPickerView?
        let pickerView = self.view.viewWithTag(PICKERVIEW_TAG)
        if(pickerView != nil) {
            picker = pickerView as? UIPickerView
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
                picker?.frame = CGRectMake(0,UIScreen.mainScreen().bounds.size.height,UIScreen.mainScreen().bounds.size.width,200)
            }) { (finish) in
                picker?.removeFromSuperview()
            }
        }
    }

    func getPickerView() -> UIPickerView? {
        var picker:UIPickerView?
        let pickerView = self.view.viewWithTag(PICKERVIEW_TAG)
        if(pickerView != nil) {
            picker = pickerView as? UIPickerView
            return picker
        }
        return picker
    }

    // MARK: - UIPickerViewDataSource
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        if selectedTextField!.isEqual(lengthTextField) {
            return 2
        }else if selectedTextField!.isEqual(weightTextField) {
            return 3
        }
        return 2
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if selectedTextField!.isEqual(lengthTextField) {
            if(component == 0) {
                return lengthArray.count
            }else{
                return 1
            }
        }else if selectedTextField!.isEqual(weightTextField) {
            if(component == 0) {
                return weightArray.count
            }else if(component == 1) {
                return weightFloatArray.count
            }else {
                return 1
            }
        }
        return 0
    }

    // MARK: - UIPickerViewDelegate
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 35
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if selectedTextField!.isEqual(lengthTextField) {
            if (component == 0) {
                return "\(lengthArray[row])"
            }else{
                return "CM"
            }
        }else if selectedTextField!.isEqual(weightTextField) {
            if(component == 0) {
                return "\(weightArray[row])"
            }else if(component == 1) {
                return ".\(weightFloatArray[row])"
            }else {
                return "KG"
            }
        }
        return ""
    }

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if selectedTextField!.isEqual(lengthTextField) {
            if component == 0 {
                lengthTextField.text = "\(lengthArray[row])"
            }
        }else if selectedTextField!.isEqual(weightTextField) {
            if component == 0 {
                selectedRow = row
            }else if component == 1 {
                selectedRow2 = row
            }
            weightTextField.text = "\(weightArray[selectedRow])"+".\(weightFloatArray[selectedRow2])"
        }
    }
}