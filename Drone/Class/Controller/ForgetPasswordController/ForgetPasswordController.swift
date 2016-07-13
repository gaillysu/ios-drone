//
//  ForgetPasswordController.swift
//  Drone
//
//  Created by leiyuncun on 16/5/26.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit
import AutocompleteField
import MRProgress
import SwiftyJSON
import BRYXBanner

class ForgetPasswordController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var newTextField: AutocompleteField!
    @IBOutlet weak var newTextField2: AutocompleteField!
    @IBOutlet weak var textBgView: UIView!
    var password_token:String = ""
    var user_id:String = ""
    var email:String = ""
    private var selectedTextField:AutocompleteField?
    
    init() {
        super.init(nibName: "ForgetPasswordController", bundle: NSBundle.mainBundle())
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    
    @IBAction func buttonManager(sender: AnyObject) {
        if sender.isEqual(backButton) {
            self.navigationController?.popViewControllerAnimated(true)
        }
        
        if sender.isEqual(confirmButton) {
            ChangePassword()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        newTextField.resignFirstResponder()
        newTextField2.resignFirstResponder()
    }
    
    func ChangePassword() {
        if newTextField2.text != nil && newTextField.text != nil{
            if newTextField.text != newTextField2.text {
                let banner = Banner(title: NSLocalizedString("Passwords don't match with each other.", comment: ""), subtitle: nil, image: nil, backgroundColor:UIColor.getBaseColor())
                banner.dismissesOnTap = true
                banner.show(duration: 1.2)
                return
            }
            
            let view = MRProgressOverlayView.showOverlayAddedTo(self.navigationController!.view, title: "Please wait...", mode: MRProgressOverlayViewMode.Indeterminate, animated: true)
            view.setTintColor(UIColor.getBaseColor())
            let timeout:NSTimer = NSTimer.after(90.seconds, {
                MRProgressOverlayView.dismissAllOverlaysForView(self.navigationController!.view, animated: true)
            })
            
            HttpPostRequest.postRequest("http://drone.karljohnchow.com/user/forget_password", data: ["user":["id":user_id, "email":email, "password":newTextField2.text!, "password_token":password_token]]) { (result) in
                
                timeout.invalidate()
                
                let jason = JSON(result)
                let user:[String:JSON] = jason["user"].dictionaryValue
                var message:String = jason["message"].stringValue
                if jason["status"].intValue == 1 && user.count>0 {
                    MRProgressOverlayView.dismissAllOverlaysForView(self.navigationController!.view, animated: true)
                    self.dismissViewControllerAnimated(true, completion: nil)
                }else{
                    MRProgressOverlayView.dismissAllOverlaysForView(self.navigationController!.view, animated: true)
                    if message.isEmpty {
                        message =  NSLocalizedString("no_network", comment: "")
                    }
                    let banner = Banner(title: NSLocalizedString(message, comment: ""), subtitle: nil, image: nil, backgroundColor:UIColor.getBaseColor())
                    banner.dismissesOnTap = true
                    banner.show(duration: 1.2)
                }
            }
        }else{
            let view = MRProgressOverlayView.showOverlayAddedTo(self.navigationController!.view, title: "Your new password cannot be empty", mode: MRProgressOverlayViewMode.Cross, animated: true)
            view.setTintColor(UIColor.getBaseColor())
            NSTimer.after(1.seconds, {
                MRProgressOverlayView.dismissAllOverlaysForView(self.navigationController!.view, animated: true)
            })
        }
    }
}

// MARK: - YYKeyboardObserver
extension ForgetPasswordController:UITextFieldDelegate {
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        selectedTextField = textField as? AutocompleteField
        return true
    }
}