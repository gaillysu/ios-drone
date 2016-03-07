//
//  RegisterController.swift
//  Nevo
//
//  Created by Karl-John on 31/12/2015.
//  Copyright © 2015 Nevo. All rights reserved.
//

import UIKit
import GSMessages

class RegisterController: UIViewController {

    @IBOutlet weak var repeatPasswordTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.title = "Register"
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        self.repeatPasswordTextField.text = "123456"
        self.passwordTextField.text = "123456"
        self.emailTextField.text="@Gmail.com"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    @IBAction func registerAction(sender: AnyObject) {
        if(repeatPasswordTextField.text != passwordTextField.text){
            self.showMessage("Password not identical", type: .Error, options: [.HideOnTap(true),
                .AutoHide(true)
                ])
            return;
        }
        if(repeatPasswordTextField.text == "" || passwordTextField.text == "" || emailTextField.text == ""){
            self.showMessage("E-mail or password is empty", type: .Error, options: [.HideOnTap(true),
                .AutoHide(true)
                ])
            return;
        }
        
        var dict:[String : AnyObject] = [:]
        dict["password"] = self.passwordTextField.text
        dict["user"] = self.emailTextField.text
        HttpPostRequest.postRequest("http://api.nevowatch.com/api/account/register", data: dict) { (result) -> Void in
            if(result["state"] as! String == "success" && result.objectForKey("uid") != nil){
                self.showMessage("User created", type: .Success, options: [.HideOnTap(true),.AutoHide(true)])
                self.delay(1.3) {
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }else{
                self.showMessage("User already exist", type: .Success, options: [.HideOnTap(true),.AutoHide(true)])
            }
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
}
