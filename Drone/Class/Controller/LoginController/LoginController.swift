//
//  LoginController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/25.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit
import GSMessages

class LoginController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        userNameTextField.text = "1508496092@qq.com"
        passwordTextField.text = "123456"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func loginButtonAction(sender: AnyObject) {
        if(self.passwordTextField.text == "" || self.userNameTextField.text == "" ){
            self.showMessage("E-mail or password is empty", type: .Error, options: [.HideOnTap(true),
                .AutoHide(true)])
            return;
        }
        var dict:[String : AnyObject] = [:]
        dict["password"] = self.passwordTextField.text
        dict["user"] = self.userNameTextField.text
        HttpPostRequest.postRequest("http://api.nevowatch.com/api/account/login", data: dict) { (result) -> Void in
            let error:String? = String(result["error"])
            if let tempErrorCode = error {
                // TODO please unwrap this, I dont get it. lol.
                if(tempErrorCode == "Optional(-12)"){
                    self.showMessage("Invalid E-mail", type: .Error, options: [.HideOnTap(true),.AutoHide(true)])
                }else if(tempErrorCode == "Optional(1)" && result["state"] as! String == "success" && result.objectForKey("uid") != nil){
                    self.showMessage("User logged in", type: .Success, options: [.HideOnTap(true),.AutoHide(true)])
                    self.delay(1.3) {
                        self.navigationController?.popViewControllerAnimated(true)
                    }

                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setBool(true, forKey: "User_Logged_In")
                    defaults.setValue(result["uid"], forKey: "User_Logged_In_UID")
                    defaults.setValue(result["token"], forKey: "User_Logged_In_Token")
                }
            }
        }
    }

    @IBAction func registerButtonAction(sender: AnyObject) {
        let registerController =  RegisterController()
        self.navigationController?.pushViewController(registerController, animated: true);
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
