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
import BRYXBanner


class CheckEmailController: UIViewController {
    
    @IBOutlet weak var emailTextField: AutocompleteField!
    @IBOutlet weak var forgotButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    init() {
        super.init(nibName: "CheckEmailController", bundle: Bundle.main)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func buttonManagerAction(_ sender: AnyObject) {
        if sender.isEqual(backButton) {
            self.dismiss(animated: true, completion: nil)
        }
        
        if sender.isEqual(forgotButton) {
            if emailTextField.text != nil {
                checkEmailAction(emailTextField.text!)
            }else{
                let view = MRProgressOverlayView.showOverlayAdded(to: self.navigationController!.view, title: "Please wait...", mode: MRProgressOverlayViewMode.cross, animated: true)
                view?.setTintColor(UIColor.getBaseColor())
                Timer.after(90.seconds, {
                    MRProgressOverlayView.dismissAllOverlays(for: self.navigationController!.view, animated: true)
                })
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailTextField.resignFirstResponder()
    }
    
    func checkEmailAction(_ email:String) {
        if AppTheme.isEmail(email) {
            let view = MRProgressOverlayView.showOverlayAdded(to: self.navigationController!.view, title: "Please wait...", mode: MRProgressOverlayViewMode.indeterminate, animated: true)
            view?.setTintColor(UIColor.getBaseColor())
            let timeout:Timer = Timer.after(90.seconds, {
                MRProgressOverlayView.dismissAllOverlays(for: self.navigationController!.view, animated: true)
            })
            
            HttpPostRequest.postRequest("http://drone.karljohnchow.com/user/request_password_token", data: ["user":["email":email]]) { (result) in
                
                timeout.invalidate()
                
                let jason = JSON(result)
                let user:[String:JSON] = jason["user"].dictionaryValue
                var message:String = jason["message"].stringValue
                
                if (jason["status"].intValue == 1 && user.count>0) {
                    MRProgressOverlayView.dismissAllOverlays(for: self.navigationController!.view, animated: true)
                    let  forget:ForgetPasswordController = ForgetPasswordController()
                    forget.password_token = user["password_token"]!.stringValue
                    forget.user_id = user["id"]!.stringValue
                    forget.email = user["email"]!.stringValue
                    self.navigationController?.pushViewController(forget, animated: true)
                }else{
                    MRProgressOverlayView.dismissAllOverlays(for: self.navigationController!.view, animated: true)
                    if message.isEmpty {
                        message =  NSLocalizedString("no_network", comment: "")
                    }
                    let banner = Banner(title: NSLocalizedString(message, comment: ""), subtitle: nil, image: nil, backgroundColor:UIColor.getBaseColor())
                    banner.dismissesOnTap = true
                    banner.show(duration: 1.2)
                }
            }
        }else{
            let view = MRProgressOverlayView.showOverlayAdded(to: self.navigationController!.view, title: "Incorrect Email address.", mode: MRProgressOverlayViewMode.cross, animated: true)
            view?.setTintColor(UIColor.getBaseColor())
            Timer.after(1.seconds, {
                MRProgressOverlayView.dismissAllOverlays(for: self.navigationController!.view, animated: true)
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// MARK: - YYKeyboardObserver
extension CheckEmailController:UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        emailTextField = textField as? AutocompleteField
        return true
    }
}
