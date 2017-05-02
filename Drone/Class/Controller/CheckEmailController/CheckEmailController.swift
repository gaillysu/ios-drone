//
//  CheckEmailController.swift
//  Drone
//
//  Created by leiyuncun on 16/5/26.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit
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
            let _:Timer = Timer.after(90.seconds, {
                MRProgressOverlayView.dismissAllOverlays(for: self.navigationController!.view, animated: true)
            })
            
            UserNetworkManager.requestPassword(email: email, completion: { (result: (success: Bool, token: String, id: Int)) in
                if result.success {
                    let  forgetPasswordController = ForgetPasswordController()
                    forgetPasswordController.password_token = result.token
                    forgetPasswordController.user_id = "\(result.id)"
                    forgetPasswordController.email = email
                    view?.dismiss(true)
                    self.navigationController?.pushViewController(forgetPasswordController, animated: true)
                }else{
                    MRProgressOverlayView.dismissAllOverlays(for: self.navigationController!.view, animated: true)
                    let banner = Banner(title: NSLocalizedString(NSLocalizedString("no_network", comment: ""), comment: ""), subtitle: nil, image: nil, backgroundColor:UIColor.getBaseColor())
                    banner.dismissesOnTap = true
                    banner.show(duration: 1.2)
                }
            })
            
        }else{
            let view = MRProgressOverlayView.showOverlayAdded(to: self.navigationController!.view, title: "Incorrect Email address.", mode: MRProgressOverlayViewMode.cross, animated: true)
            view?.setTintColor(UIColor.getBaseColor())
            Timer.after(1.seconds, {
                MRProgressOverlayView.dismissAllOverlays(for: self.navigationController!.view, animated: true)
            })
        }
    }

}

// MARK: - YYKeyboardObserver
extension CheckEmailController:UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        emailTextField = textField as? AutocompleteField
        return true
    }
}
