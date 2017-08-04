//
//  ProfileController.swift
//  Nevo
//
//  Created by leiyuncun on 16/3/2.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import UIColor_Hex_Swift
import BRYXBanner
import SwiftyJSON
import MRProgress
import RxSwift

class ProfileSetupViewController: BaseViewController {
    
    @IBOutlet weak var backB: UIButton!
    @IBOutlet weak var nextB: UIButton!
    @IBOutlet weak var textfiledBG: UIView!
    @IBOutlet weak var birthdayTextField: AutocompleteField!
    @IBOutlet weak var heightTextField: AutocompleteField!
    @IBOutlet weak var weightTextField: AutocompleteField!
    @IBOutlet weak var metricsSegment: UIView!
    
    @IBOutlet weak var lastNameTextField: AutocompleteField!
    @IBOutlet weak var firstNameTextField: AutocompleteField!
    
    @IBOutlet weak var genderSegmentView: UISegmentedControl!
    fileprivate var nameDictionary:Dictionary<String,AnyObject> = ["first_name":"DroneUser" as AnyObject,"last_name":"User" as AnyObject]
    var account:Dictionary<String,AnyObject> = ["email":"" as AnyObject,"password":"" as AnyObject]
    
    var datePicker:UIDatePicker?
    var picker:UIPickerView?
    
    fileprivate enum TextFieldType{
        case height
        case weight
    }
    
    fileprivate var selectedTextFieldType:TextFieldType?
    
    fileprivate var lengthArray:[Int] = Array(100...250)
    fileprivate var weightArray:[Int] = Array(35...150)
    fileprivate var weightFloatArray:[Int] = Array(0...9)
    
    var disposeBag = DisposeBag()
    
    init() {
        super.init(nibName: "ProfileSetupViewController", bundle: Bundle.main)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker = UIDatePicker()
        datePicker?.maximumDate = Date()
        datePicker?.datePickerMode = .date
        datePicker?.rx.controlEvent(.valueChanged).subscribe({ _ in
            self.birthdayTextField.text = self.dateFormattedStringWithFormat((self.datePicker?.date)!)
        }).addDisposableTo(disposeBag)
        birthdayTextField.inputView = datePicker
        
        picker = UIPickerView()
        picker?.delegate = self
        picker?.dataSource = self
        weightTextField.inputView = picker
        weightTextField.rx.controlEvent(UIControlEvents.editingDidBegin).subscribe { _ in
            self.selectedTextFieldType = .weight
            }.addDisposableTo(disposeBag)
        heightTextField.inputView = picker
        heightTextField.rx.controlEvent(UIControlEvents.editingDidBegin).subscribe { _ in
            self.selectedTextFieldType = .height
            }.addDisposableTo(disposeBag)
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
        weightTextField.resignFirstResponder()
        lastNameTextField.resignFirstResponder()
        firstNameTextField.resignFirstResponder()
    }
    
    func registerRequest() {
            if(AppTheme.isNull(birthdayTextField!.text!) || AppTheme.isEmail(heightTextField!.text!) || AppTheme.isEmail(weightTextField!.text!) || AppTheme.isNull(firstNameTextField.text!) || AppTheme.isNull(lastNameTextField.text!)) {
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
            
            let sex:Int = self.genderSegmentView.selectedSegmentIndex == 0 ? 1 : 0
            UserNetworkManager.createUser(firstName: self.firstNameTextField.text!, lastName: self.lastNameTextField.text!, email: email, password: password, birthday: birthdayTextField.text!, length: heightTextField.text!, weight: weightTextField.text!, sex: sex, completion: { accountCreated in
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
    }
    
    func dateFormattedStringWithFormat(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}

// MARK: - UIPickerView
extension ProfileSetupViewController:UIPickerViewDelegate,UIPickerViewDataSource {
    
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if let type  = selectedTextFieldType {
            switch type {
            case .height:
                return 2
            case .weight:
                return 3
            }
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let type = selectedTextFieldType {
            switch type {
            case .height:
                if(component == 0) {
                    return lengthArray.count
                }else{
                    return 1
                }
            case .weight:
                if(component == 0) {
                    return weightArray.count
                }else if(component == 1) {
                    return weightFloatArray.count
                }else {
                    return 1
                }
            }
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let type = selectedTextFieldType {
            switch type {
            case .height:
                if component == 0 {
                    return "\(lengthArray[row])"
                }
                return "CM"
            case .weight:
                if(component == 0) {
                    return "\(weightArray[row])"
                }else if(component == 1) {
                    return ".\(weightFloatArray[row])"
                }
                return "KG"
            }
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let type = selectedTextFieldType {
            switch type {
            case .height:
                    heightTextField.text = "\(lengthArray[row]) CM"
            case .weight:
                weightTextField.text = "\(weightArray[pickerView.selectedRow(inComponent: 0)])"+".\(weightFloatArray[pickerView.selectedRow(inComponent: 1)]) KG"
            }
        }
    }
}
