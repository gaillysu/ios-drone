//
//  ProfileTableViewCell.swift
//  Drone
//
//  Created by Karl-John on 3/5/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation

class ProfileTableViewCell: UITableViewCell, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
   
    private var inputVariables: NSMutableArray = NSMutableArray()
    private var keyBoardType:Type?{
        didSet {
            if keyBoardType == Type.Email {
//                itemTextField.enabled = false
//                editButton.hidden = true
            }
        }
    }
    
    var textPreFix = "";
    var textPostFix = "";
    var cellIndex:Int = 0
    var editCellTextField:((index:Int, text:String) -> Void)?
    
    enum Type{
        case Numeric
        case Text
        case Email
        case Date
    }
    
    @IBOutlet weak var itemTextField: UITextField!
    @IBOutlet weak var editButton: UIButton!
    
    override func awakeFromNib() {
        itemTextField.delegate = self;
        separatorInset = UIEdgeInsetsZero
        preservesSuperviewLayoutMargins = false
        layoutMargins = UIEdgeInsetsZero
    }
    
    @IBAction func editButtonAction(sender: AnyObject) {
        if itemTextField.isFirstResponder() {
            itemTextField.resignFirstResponder()
        }else{
            itemTextField.becomeFirstResponder()
        }
    }
    
    func setInputVariables(vars:NSMutableArray){
        self.inputVariables = vars
    }
    
    func setType(type:Type){
        keyBoardType = type
        if type == Type.Email {
            itemTextField.keyboardType = UIKeyboardType.EmailAddress
        }else if type == Type.Numeric {
            let picker = UIPickerView();
            picker.delegate = self;
            picker.dataSource = self;
            itemTextField.inputView = picker;
        }else if type == Type.Date {
            let datePicker:UIDatePicker = UIDatePicker()
            datePicker.datePickerMode = UIDatePickerMode.Date
            itemTextField.inputView = datePicker
            datePicker.addTarget(self, action: #selector(selectedDateAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        }else{
            itemTextField.keyboardType = UIKeyboardType.Default
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= 25
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if keyBoardType == Type.Date {
            editCellTextField?(index: cellIndex,text: textField.text!.componentsSeparatedByString(" ")[1])
        }else{
            editCellTextField?(index: cellIndex,text: textField.text!)
        }
        
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return true;
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return inputVariables.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(inputVariables[row])"+"\(textPostFix)"
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        itemTextField.text = "\(textPreFix)"+"\(inputVariables[row])"+"\(textPostFix)"
        editCellTextField?(index: cellIndex,text: "\(inputVariables[row])")
    }
    
    func selectedDateAction(date:UIDatePicker) {
        NSLog("date:\(date.date)")
        itemTextField.text = "\(textPreFix)"+self.dateFormattedStringWithFormat("yyyy-MM-dd", fromDate: date.date)
        editCellTextField?(index: cellIndex,text: self.dateFormattedStringWithFormat("yyyy-MM-dd", fromDate: date.date))
    }
    
    func dateFormattedStringWithFormat(format: String, fromDate date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = format
        return formatter.stringFromDate(date)
    }
}