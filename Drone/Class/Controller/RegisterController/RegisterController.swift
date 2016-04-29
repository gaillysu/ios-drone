//
//  RegisterController.swift
//  Nevo
//
//  Created by Karl-John on 31/12/2015.
//  Copyright © 2015 Nevo. All rights reserved.
//

import UIKit
import GSMessages
import AutocompleteField
import BRYXBanner

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
            passwordT!.placeholder = "Password"
            passwordT?.backgroundColor = UIColor.whiteColor()
            textfiledBG.addSubview(passwordT!)
        }
        
    }

    @IBAction func buttonActionManager(sender: AnyObject) {

        if backB.isEqual(sender) {
            self.navigationController?.popViewControllerAnimated(true)
        }

        if nextB.isEqual(sender) {
            if(AppTheme.isNull(passwordT.text!) || AppTheme.isNull(emailT.text!)) {
                let banner = Banner(title: NSLocalizedString("email or password is null", comment: ""), subtitle: nil, image: nil, backgroundColor:UIColor.redColor())
                banner.dismissesOnTap = true
                banner.show(duration: 0.7)
                return
            }
            let profile:ProfileViewController = ProfileViewController()
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
