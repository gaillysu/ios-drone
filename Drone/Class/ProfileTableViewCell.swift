//
//  ProfileTableViewCell.swift
//  Drone
//
//  Created by Karl-John on 3/5/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation

class ProfileTableViewCell: UITableViewCell, UITextFieldDelegate {
   
    @IBOutlet weak var itemTextField: UITextField!
    @IBOutlet weak var editButton: UIButton!
    
    override func awakeFromNib() {
        itemTextField.delegate = self;
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= 15
    }
}