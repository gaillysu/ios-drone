//
//  ProfileTableViewCell.swift
//  Drone
//
//  Created by Karl-John on 3/5/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import UIKit
class ProfileTableViewCell: UITableViewCell, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
   
    fileprivate var inputVariables: NSMutableArray = NSMutableArray()
    fileprivate var keyBoardType:Type?{
        didSet {
            if keyBoardType == Type.email {
//                itemTextField.enabled = false
//                editButton.hidden = true
            }
        }
    }
    
    var textPreFix = "";
    var textPostFix = "";
    var cellIndex:Int = 0
    var editCellTextField:((_ index:Int, _ text:String) -> Void)?
    
    enum `Type`{
        case numeric
        case text
        case email
        case date
    }
    
    @IBOutlet weak var itemTextField: UITextField!
    @IBOutlet weak var editButton: UIButton!
    
    override func awakeFromNib() {
        itemTextField.delegate = self;
        separatorInset = UIEdgeInsets.zero
        preservesSuperviewLayoutMargins = false
        layoutMargins = UIEdgeInsets.zero
    }
    
    @IBAction func editButtonAction(_ sender: AnyObject) {
        if itemTextField.isFirstResponder {
            itemTextField.resignFirstResponder()
        }else{
            itemTextField.becomeFirstResponder()
        }
    }
    
    func setInputVariables(_ vars:NSMutableArray){
        self.inputVariables = vars
    }
    
    func setType(_ type:Type){
        keyBoardType = type
        if type == Type.email {
            itemTextField.keyboardType = UIKeyboardType.emailAddress
        }else if type == Type.numeric {
            let picker = UIPickerView();
            picker.delegate = self;
            picker.dataSource = self;
            itemTextField.inputView = picker;
        }else if type == Type.date {
            let datePicker:UIDatePicker = UIDatePicker()
            datePicker.datePickerMode = UIDatePickerMode.date
            itemTextField.inputView = datePicker
            datePicker.addTarget(self, action: #selector(selectedDateAction(_:)), for: UIControlEvents.valueChanged)
        }else{
            itemTextField.keyboardType = UIKeyboardType.default
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= 25
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if keyBoardType == Type.date {
            editCellTextField?(cellIndex,textField.text!.components(separatedBy: " ")[1])
        }else{
            editCellTextField?(cellIndex,textField.text!)
        }
        
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true;
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return inputVariables.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(inputVariables[row])"+"\(textPostFix)"
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        itemTextField.text = "\(textPreFix)"+"\(inputVariables[row])"+"\(textPostFix)"
        editCellTextField?(cellIndex,"\(inputVariables[row])")
    }
    
    func selectedDateAction(_ date:UIDatePicker) {
        NSLog("date:\(date.date)")
        itemTextField.text = "\(textPreFix)"+self.dateFormattedStringWithFormat("yyyy-MM-dd", fromDate: date.date)
        editCellTextField?(cellIndex,self.dateFormattedStringWithFormat("yyyy-MM-dd", fromDate: date.date))
    }
    
    func dateFormattedStringWithFormat(_ format: String, fromDate date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}
