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
import BRYXBanner
import SwiftyJSON
import MRProgress
import XCGLogger
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


private let DATEPICKER_TAG:Int = 1280
private let PICKERVIEW_TAG:Int = 1380

class ProfileSetupViewController: BaseViewController,SMSegmentViewDelegate {

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
    fileprivate var nameDictionary:Dictionary<String,AnyObject> = ["first_name":"DroneUser" as AnyObject,"last_name":"User" as AnyObject]
    var account:Dictionary<String,AnyObject> = ["email":"" as AnyObject,"password":"" as AnyObject]

    fileprivate var selectedTextField: AutocompleteField?
    fileprivate var lengthArray:[Int] = []
    fileprivate var weightArray:[Int] = []
    fileprivate var weightFloatArray:[Int] = []
    fileprivate var selectedRow:Int = 0
    fileprivate var selectedRow2:Int = 0

    init() {
        super.init(nibName: "ProfileSetupViewController", bundle: Bundle.main)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        textfiledBG.layer.borderColor = UIColor(rgba: "#6F7179").cgColor
        //Init pickerView the data
        for index:Int in 100...250 {
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
            let segmentProperties = ["OnSelectionBackgroundColour": UIColor.getBaseColor(),"OffSelectionBackgroundColour": UIColor.white,"OnSelectionTextColour": UIColor.white,"OffSelectionTextColour": UIColor(rgba: "#95989a")]

            let segmentFrame = CGRect(x: 0, y: 0, width: metricsSegment.frame.size.width, height: metricsSegment.frame.size.height)
            segmentView = SMSegmentView(frame: segmentFrame, separatorColour: UIColor(white: 0.95, alpha: 0.3), separatorWidth: 1.0, segmentProperties: segmentProperties)
            segmentView!.delegate = self
            segmentView!.layer.borderColor = UIColor(white: 0.85, alpha: 1.0).cgColor
            segmentView!.layer.borderWidth = 1.0

            // Add segments
            _ = segmentView!.addSegmentWithTitle("Male", onSelectionImage: nil, offSelectionImage: nil)
            _ = segmentView!.addSegmentWithTitle("Female", onSelectionImage: nil, offSelectionImage: nil)
            segmentView?.selectSegmentAtIndex(0)
            metricsSegment.addSubview(segmentView!)
        }
    }

    @IBAction func buttonActionManager(_ sender: AnyObject) {
        if (backB.isEqual(sender)) {
            _ = self.navigationController?.popViewController(animated: true)
        }

        if (nextB.isEqual(sender)) {
            registerRequest()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        ageTextField.resignFirstResponder()
        lengthTextField.resignFirstResponder()
        weightTextField.resignFirstResponder()
        lastNameTextField.resignFirstResponder()
        firstNameTextField.resignFirstResponder()
        self.removeDatePickerView()
        self.removePickerView()
    }

    // MARK: - SMSegmentViewDelegate
    func segmentView(_ segmentView: SMBasicSegmentView, didSelectSegmentAtIndex index: Int) {
        debugPrint("Select segment at index: \(index)")
    }

    func registerRequest() {
        if AppDelegate.getAppDelegate().network!.isReachable {
            if(AppTheme.isNull(ageTextField!.text!) || AppTheme.isEmail(lengthTextField!.text!) || AppTheme.isEmail(weightTextField!.text!) || AppTheme.isNull(firstNameTextField.text!) || AppTheme.isNull(lastNameTextField.text!)) {
                let banner = Banner(title: NSLocalizedString("One of the fields are empty.", comment: ""), subtitle: nil, image: nil, backgroundColor:UIColor.getBaseColor())
                banner.dismissesOnTap = true
                banner.show(duration: 0.6)
                return
            }
            
            let email:String = account["email"] as! String
            let password:String = account["password"] as! String
            
            let view = MRProgressOverlayView.showOverlayAdded(to: self.navigationController!.view, title: "Please wait...", mode: MRProgressOverlayViewMode.indeterminate, animated: true)
            view?.setTintColor(UIColor.getBaseColor())
            
            //timeout
            let timeout:Timer = Timer.after(90.seconds, {
                MRProgressOverlayView.dismissAllOverlays(for: self.navigationController!.view, animated: true)
            })
            
            let sex:Int = self.segmentView?.indexOfSelectedSegment == 0 ? 1 : 0
            UserNetworkManager.createUser(firstName: self.firstNameTextField.text!, lastName: self.lastNameTextField.text!, email: email, password: password, birthday: ageTextField.text!, length: lengthTextField.text!, weight: weightTextField.text!, sex: sex, completion: { accountCreated in
                var message = ""
                timeout.invalidate()
                if accountCreated {
                    let device:WhichDeviceViewController = WhichDeviceViewController(toMenu: false)
                    self.navigationController?.pushViewController(device, animated: true)
                    message = NSLocalizedString("created_account", comment: "")
                }else{
                    message = NSLocalizedString("no_network", comment: "")
                }
                let banner = Banner(title: NSLocalizedString(message, comment: ""), subtitle: nil, image: nil, backgroundColor:UIColor.getBaseColor())
                banner.dismissesOnTap = true
                banner.show(duration: 1.2)
            })
        }else{
            XCGLogger.debug("注册的时候没有网络")
            let view = MRProgressOverlayView.showOverlayAdded(to: self.navigationController!.view, title: "No internet", mode: MRProgressOverlayViewMode.cross, animated: true)
            view?.setTintColor(UIColor.getBaseColor())
            _ = Timer.after(0.6.seconds, {
                MRProgressOverlayView.dismissAllOverlays(for: self.navigationController!.view, animated: true)
            })
        }
    }
}

extension ProfileSetupViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {

    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if(textField.isEqual(ageTextField)) {
            textField.resignFirstResponder()
        }
        return true
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
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
            datePicker = UIDatePicker(frame: CGRect(x: 0,y: UIScreen.main.bounds.size.height,width: UIScreen.main.bounds.size.width,height: 200))
            datePicker?.datePickerMode = UIDatePickerMode.date
            datePicker?.backgroundColor = UIColor.white
            datePicker?.tag = DATEPICKER_TAG
            self.view.addSubview(datePicker!)
            datePicker?.addTarget(self, action: #selector(ProfileSetupViewController.selectedDateAction(_:)), for: UIControlEvents.valueChanged)
        }else{
            datePicker = picker as? UIDatePicker
        }

        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
            datePicker?.frame = CGRect(x: 0,y: datePicker?.frame.origin.y>=UIScreen.main.bounds.size.height ? (UIScreen.main.bounds.size.height-200):(UIScreen.main.bounds.size.height),width: UIScreen.main.bounds.size.width,height: 200)
            }) { (finish) in
                if(datePicker?.frame.origin.y>UIScreen.main.bounds.size.height) {
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

    func selectedDateAction(_ date:UIDatePicker) {
        NSLog("date:\(date.date)")
        ageTextField.text = self.dateFormattedStringWithFormat("yyyy-MM-dd", fromDate: date.date)
    }

    func dateFormattedStringWithFormat(_ format: String, fromDate date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}

// MARK: - UIPickerView
extension ProfileSetupViewController:UIPickerViewDelegate,UIPickerViewDataSource {

    func selectedLength() {
        var picker:UIPickerView?
        let pickerView = self.view.viewWithTag(PICKERVIEW_TAG)
        if (pickerView == nil) {
            picker = UIPickerView(frame: CGRect(x: 0,y: UIScreen.main.bounds.size.height,width: UIScreen.main.bounds.size.width,height: 200))
            picker?.backgroundColor = UIColor.white
            picker?.tag = PICKERVIEW_TAG
            picker?.delegate = self
            self.view.addSubview(picker!)
        }else{
            picker = pickerView as? UIPickerView
        }

        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
            picker?.frame = CGRect(x: 0,y: UIScreen.main.bounds.size.height-200,width: UIScreen.main.bounds.size.width,height: 200)
        }) { (finish) in
            if(picker?.frame.origin.y>UIScreen.main.bounds.size.height) {
                picker?.removeFromSuperview()
            }
        }
    }

    func removePickerView() {
        var picker:UIPickerView?
        let pickerView = self.view.viewWithTag(PICKERVIEW_TAG)
        if(pickerView != nil) {
            picker = pickerView as? UIPickerView
            UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                picker?.frame = CGRect(x: 0,y: UIScreen.main.bounds.size.height,width: UIScreen.main.bounds.size.width,height: 200)
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
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if selectedTextField!.isEqual(lengthTextField) {
            return 2
        }else if selectedTextField!.isEqual(weightTextField) {
            return 3
        }
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
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
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 35
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
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

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
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
