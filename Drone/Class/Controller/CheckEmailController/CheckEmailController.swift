//
//  CheckEmailController.swift
//  Drone
//
//  Created by leiyuncun on 16/5/26.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit
import AutocompleteField
import SwiftyJSON
import MRProgress
import YYKeyboardManager
import BRYXBanner


class CheckEmailController: UIViewController {

    
    @IBOutlet weak var emailTextField: AutocompleteField!
    @IBOutlet weak var forgotButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    init() {
        super.init(nibName: "CheckEmailController", bundle: NSBundle.mainBundle())
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        YYKeyboardManager.defaultManager().addObserver(self)
    }

    @IBAction func buttonManagerAction(sender: AnyObject) {
        if sender.isEqual(backButton) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        if sender.isEqual(forgotButton) {
            if emailTextField.text != nil {
                checkEmailAction(emailTextField.text!)
            }else{
                let view = MRProgressOverlayView.showOverlayAddedTo(self.navigationController!.view, title: "Please wait...", mode: MRProgressOverlayViewMode.Cross, animated: true)
                view.setTintColor(UIColor.getBaseColor())
                NSTimer.after(90.seconds, {
                    MRProgressOverlayView.dismissAllOverlaysForView(self.navigationController!.view, animated: true)
                })
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        emailTextField.resignFirstResponder()
    }
    
    func checkEmailAction(email:String) {
        if AppTheme.isEmail(email) {
            let view = MRProgressOverlayView.showOverlayAddedTo(self.navigationController!.view, title: "Please wait...", mode: MRProgressOverlayViewMode.Indeterminate, animated: true)
            view.setTintColor(UIColor.getBaseColor())
            let timeout:NSTimer = NSTimer.after(90.seconds, {
                MRProgressOverlayView.dismissAllOverlaysForView(self.navigationController!.view, animated: true)
            })
            
            HttpPostRequest.postRequest("http://drone.karljohnchow.com/user/request_password_token", data: ["user":["email":email]]) { (result) in
                
                timeout.invalidate()
                
                let jason = JSON(result)
                let user:[String:JSON] = jason["user"].dictionaryValue
                var message:String = jason["message"].stringValue
                
                if (jason["status"].intValue == 1 && user.count>0) {
                    MRProgressOverlayView.dismissAllOverlaysForView(self.navigationController!.view, animated: true)
                    let  forget:ForgetPasswordController = ForgetPasswordController()
                    forget.password_token = user["password_token"]!.stringValue
                    forget.user_id = user["id"]!.stringValue
                    forget.email = user["email"]!.stringValue
                    self.navigationController?.pushViewController(forget, animated: true)
                }else{
                    MRProgressOverlayView.dismissAllOverlaysForView(self.navigationController!.view, animated: true)
                    if message.isEmpty {
                        message =  NSLocalizedString("no_network", comment: "")
                    }
                    let banner = Banner(title: NSLocalizedString(message, comment: ""), subtitle: nil, image: nil, backgroundColor:UIColor.redColor())
                    banner.dismissesOnTap = true
                    banner.show(duration: 1.2)
                }
            }
        }else{
            let view = MRProgressOverlayView.showOverlayAddedTo(self.navigationController!.view, title: "Your email address error", mode: MRProgressOverlayViewMode.Cross, animated: true)
            view.setTintColor(UIColor.getBaseColor())
            NSTimer.after(1.seconds, {
                MRProgressOverlayView.dismissAllOverlaysForView(self.navigationController!.view, animated: true)
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// MARK: - YYKeyboardObserver
extension CheckEmailController:YYKeyboardObserver,UITextFieldDelegate {
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        emailTextField = textField as? AutocompleteField
        return true
    }
    
    func keyboardChangedWithTransition(transition: YYKeyboardTransition) {
        UIView.animateWithDuration(transition.animationDuration, delay: 0, options: transition.animationOption, animations: {
            let kbFrame:CGRect = YYKeyboardManager.defaultManager().convertRect(transition.toFrame, toView: self.view)
            let textFrame:CGRect = self.emailTextField!.frame
            if((textFrame.origin.y+textFrame.size.height)>kbFrame.origin.y) {
                self.view.frame = CGRectMake(0, -((textFrame.origin.y+textFrame.size.height)-kbFrame.origin.y), UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
                
            }else{
                self.view.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
            }
        }) { (finished) in
            
        }
    }
    
}