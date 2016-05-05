//
//  ProfileTableViewCellHeader.swift
//  Drone
//
//  Created by Karl-John on 3/5/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation

class ProfileTableViewCellHeader: UIView, UITextFieldDelegate{
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var editButton: UIButton!
 
    @IBAction func editButtonAction(sender: AnyObject) {
        nameTextField.becomeFirstResponder()
    }
    
    override func awakeFromNib() {
        nameTextField.delegate = self;
        preservesSuperviewLayoutMargins = false
        layoutMargins = UIEdgeInsetsZero
    }
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= 15
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return true;
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }    
}