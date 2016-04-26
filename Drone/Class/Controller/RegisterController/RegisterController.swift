//
//  RegisterController.swift
//  Nevo
//
//  Created by Karl-John on 31/12/2015.
//  Copyright © 2015 Nevo. All rights reserved.
//

import UIKit
import AutocompleteField

class RegisterController: BaseViewController {
    @IBOutlet weak var backB: UIButton!
    @IBOutlet weak var nextB: UIButton!
    @IBOutlet weak var textfiledBG: UIView!
    @IBOutlet weak var registerL: UILabel!
    @IBOutlet weak var googleB: UIButton!
    @IBOutlet weak var facebookB: UIButton!
    @IBOutlet weak var twitterB: UIButton!

    var emailT: AutocompleteField!
    var passwordT: AutocompleteField!

    init() {
        super.init(nibName: "RegisterController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewDidLayoutSubviews() {
        if (emailT == nil) {
            emailT = AutocompleteField(frame: CGRectMake(0, 0, textfiledBG.frame.size.width, textfiledBG.frame.size.height/2.0-0.5))
            emailT!.padding = 5.0
            emailT!.placeholder = "Email"
            emailT?.backgroundColor = UIColor.whiteColor()
            textfiledBG.addSubview(emailT!)

            passwordT = AutocompleteField(frame: CGRectMake(0, textfiledBG.frame.size.height/2.0, textfiledBG.frame.size.width, textfiledBG.frame.size.height/2.0-0.5))
            passwordT!.padding = 5.0
            passwordT!.secureTextEntry = true
            passwordT!.placeholder = "Password"
            passwordT?.backgroundColor = UIColor.whiteColor()
            textfiledBG.addSubview(passwordT!)

            let displaypassword:UIButton = UIButton(type: UIButtonType.Custom)
            displaypassword.frame = CGRectMake(0, 0, 30, 30)
            displaypassword.setImage(UIImage(named: "check"), forState: UIControlState.Normal)
            displaypassword.addTarget(self, action: #selector(RegisterController.displayPasswordAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
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
