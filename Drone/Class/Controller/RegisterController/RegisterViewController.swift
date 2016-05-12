//
//  RegisterController.swift
//  Nevo
//
//  Created by Karl-John on 31/12/2015.
//  Copyright © 2015 Nevo. All rights reserved.
//

import UIKit
import AutocompleteField
import BRYXBanner
import YYKeyboardManager


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

    init(fromMenu: Bool = false) {
        self.fromMenu = fromMenu
        super.init(nibName: "RegisterViewController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        YYKeyboardManager.defaultManager().addObserver(self)
    }

    override func viewDidLayoutSubviews() {
        if (emailT == nil) {
            emailT = AutocompleteField(frame: CGRectMake(0, 0, textfiledBG.frame.size.width, textfiledBG.frame.size.height/2.0-0.5))
            emailT!.padding = 5.0
            emailT!.placeholder = "E-mail"
            emailT?.backgroundColor = UIColor.whiteColor()
            textfiledBG.addSubview(emailT!)

            passwordT = AutocompleteField(frame: CGRectMake(0, textfiledBG.frame.size.height/2.0, textfiledBG.frame.size.width, textfiledBG.frame.size.height/2.0-0.5))
            passwordT!.padding = 5.0
            passwordT!.secureTextEntry = true
            passwordT!.placeholder = "Password"
            passwordT?.backgroundColor = UIColor.whiteColor()
            textfiledBG.addSubview(passwordT!)

            let displaypassword:UIButton = UIButton(type: UIButtonType.Custom)
            displaypassword.frame = CGRectMake(0, 0, 40, 30)
            displaypassword.setImage(UIImage(named: "check"), forState: UIControlState.Normal)
            displaypassword.imageEdgeInsets.right = 10
            displaypassword.addTarget(self, action: #selector(RegisterViewController.displayPasswordAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            passwordT.rightViewMode = UITextFieldViewMode.Always
            passwordT.rightView = displaypassword
        }
        
    }

    func displayPasswordAction(sender:UIButton) {
        if passwordT!.secureTextEntry {
            passwordT!.secureTextEntry = false
        }else{
            passwordT!.secureTextEntry = true
        }
    }

    @IBAction func buttonActionManager(sender: AnyObject) {

        if backB.isEqual(sender) {
            self.navigationController?.popViewControllerAnimated(true)
        }

        if nextB.isEqual(sender) {
            let profile:ProfileSetupViewController = ProfileSetupViewController()
            if(AppTheme.isNull(passwordT.text!) || AppTheme.isNull(emailT.text!)) {
                let banner = Banner(title: NSLocalizedString("email or password is null", comment: ""), subtitle: nil, image: nil, backgroundColor:UIColor.redColor())
                banner.dismissesOnTap = true
                banner.show(duration: 0.7)
                return
            }
            profile.account = ["email":emailT.text!,"password":passwordT.text!]
            self.navigationController?.pushViewController(profile, animated: true)
        }

        if googleB.isEqual(sender) {
        }

        if facebookB.isEqual(sender) {
        }

        if twitterB.isEqual(sender) {
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        emailT.resignFirstResponder()
        passwordT.resignFirstResponder()
    }
}

// MARK: - YYKeyboardObserver
extension RegisterViewController:YYKeyboardObserver {
    func keyboardChangedWithTransition(transition: YYKeyboardTransition) {
        UIView.animateWithDuration(transition.animationDuration, delay: 0, options: transition.animationOption, animations: {
            let kbFrame:CGRect = YYKeyboardManager.defaultManager().convertRect(transition.toFrame, toView: self.view)
            let kbY:CGFloat = self.view.frame.origin.y < 0 ? 0:kbFrame.origin.y - UIScreen.mainScreen().bounds.size.height
            self.view.frame = CGRectMake(0, kbY, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
        }) { (finished) in

        }
    }

}
