//
//  RegisterController.swift
//  Nevo
//
//  Created by Karl-John on 31/12/2015.
//  Copyright © 2015 Nevo. All rights reserved.
//

import UIKit
import BRYXBanner

class RegisterViewController: BaseViewController {
    @IBOutlet weak var backB: UIButton!
    @IBOutlet weak var nextB: UIButton!
    @IBOutlet weak var textfiledBG: UIView!
    @IBOutlet weak var registerL: UILabel!
    @IBOutlet weak var googleB: UIButton!
    @IBOutlet weak var facebookB: UIButton!
    @IBOutlet weak var twitterB: UIButton!
    
    var fromMenu: Bool = false;
    var emailT: AutocompleteField!
    var passwordT: AutocompleteField!
    fileprivate var selectedTextField:AutocompleteField?

    init(fromMenu: Bool = false) {
        self.fromMenu = fromMenu
        super.init(nibName: "RegisterViewController", bundle: Bundle.main)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewDidLayoutSubviews() {
        if (emailT == nil) {
            emailT = AutocompleteField(frame: CGRect(x: 0, y: 0, width: textfiledBG.frame.size.width, height: textfiledBG.frame.size.height/2.0-0.5))
            emailT!.padding = 5.0
            emailT!.placeholder = "E-mail"
            emailT?.backgroundColor = UIColor.white
            emailT.delegate = self
            textfiledBG.addSubview(emailT!)

            passwordT = AutocompleteField(frame: CGRect(x: 0, y: textfiledBG.frame.size.height/2.0, width: textfiledBG.frame.size.width, height: textfiledBG.frame.size.height/2.0-0.5))
            passwordT!.padding = 5.0
            passwordT!.isSecureTextEntry = true
            passwordT!.placeholder = "Password"
            passwordT?.backgroundColor = UIColor.white
            passwordT.delegate = self
            textfiledBG.addSubview(passwordT!)

            let displaypassword:UIButton = UIButton(type: UIButtonType.custom)
            displaypassword.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
            displaypassword.setImage(UIImage(named: "check"), for: UIControlState())
            displaypassword.imageEdgeInsets.right = 10
            displaypassword.addTarget(self, action: #selector(RegisterViewController.displayPasswordAction(_:)), for: UIControlEvents.touchUpInside)
            passwordT.rightViewMode = UITextFieldViewMode.always
            passwordT.rightView = displaypassword
        }
        
    }

    func displayPasswordAction(_ sender:UIButton) {
        if passwordT!.isSecureTextEntry {
            passwordT!.isSecureTextEntry = false
        }else{
            passwordT!.isSecureTextEntry = true
        }
    }

    @IBAction func buttonActionManager(_ sender: AnyObject) {

        if backB.isEqual(sender) {
            _ = self.navigationController?.popViewController(animated: true)
        }

        if nextB.isEqual(sender) {
            let profile:ProfileSetupViewController = ProfileSetupViewController()
            if(AppTheme.isNull(passwordT.text!) || AppTheme.isNull(emailT.text!)) {
                let banner = Banner(title: NSLocalizedString("email or password is null", comment: ""), subtitle: nil, image: nil, backgroundColor:UIColor.getBaseColor())
                banner.dismissesOnTap = true
                banner.show(duration: 0.7)
                return
            }
            profile.account = ["email":emailT.text! as AnyObject,"password":passwordT.text! as AnyObject]
            self.navigationController?.pushViewController(profile, animated: true)
        }

        if googleB.isEqual(sender) {
        }

        if facebookB.isEqual(sender) {
        }

        if twitterB.isEqual(sender) {
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailT.resignFirstResponder()
        passwordT.resignFirstResponder()
    }
}

// MARK: - YYKeyboardObserver
extension RegisterViewController:UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        selectedTextField = textField as? AutocompleteField
        return true
    }
}
