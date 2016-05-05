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
    var textPreFix = "";
    var textPostFix = "";
    
    enum Type{
        case Numeric
        case Text
        case Email
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
        itemTextField.becomeFirstResponder()
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= 15
    }
    
    func setInputVariables(vars:NSMutableArray){
        self.inputVariables = vars
    }
    
    func setType(type:Type){
        if type == Type.Email {
            itemTextField.keyboardType = UIKeyboardType.EmailAddress
        }else if type == Type.Numeric {
            let picker = UIPickerView();
            picker.delegate = self;
            picker.dataSource = self;
            itemTextField.inputView = picker;
        }else{
            itemTextField.keyboardType = UIKeyboardType.Default
        }
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return true;
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return inputVariables.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(inputVariables[row])"+"\(textPostFix)"
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        itemTextField.text = "\(textPreFix)"+"\(inputVariables[row])"+"\(textPostFix)"
    }
}