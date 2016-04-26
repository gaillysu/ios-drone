//
//  LoginController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/25.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit
import AutocompleteField
import Crashlytics

class LoginController: UIViewController {

    @IBOutlet weak var backB: UIButton!
    @IBOutlet weak var nextB: UIButton!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var loginL: UILabel!
    @IBOutlet weak var textfiledBG: UIView!
    @IBOutlet weak var googleB: UIButton!
    @IBOutlet weak var facebookB: UIButton!
    @IBOutlet weak var twitterB: UIButton!
    var usernameT: AutocompleteField?
    var passwordT: AutocompleteField?

    init() {
        super.init(nibName: "LoginController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewDidLayoutSubviews() {
        let button = UIButton(type: UIButtonType.RoundedRect)
        button.frame = CGRectMake(20, 50, 100, 30)
        button.setTitle("Crash", forState: UIControlState.Normal)
        button.addTarget(self, action: "crashButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(button)


        if (usernameT == nil) {
            usernameT = AutocompleteField(frame: CGRectMake(0, 0, textfiledBG.frame.size.width, textfiledBG.frame.size.height/2.0-0.5))
            usernameT!.padding = 15.0
            usernameT?.font = UIFont(name: usernameT!.font!.fontName, size: 15);
            usernameT!.placeholder = "Username"
            usernameT?.backgroundColor = UIColor.whiteColor()
            textfiledBG.addSubview(usernameT!)

            passwordT = AutocompleteField(frame: CGRectMake(0, textfiledBG.frame.size.height/2.0, textfiledBG.frame.size.width, textfiledBG.frame.size.height/2.0-0.5))
            passwordT!.padding = 15.0
            passwordT?.font = UIFont(name: usernameT!.font!.fontName, size: 15);
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

        }

        if googleB.isEqual(sender) {

        }

        if facebookB.isEqual(sender) {

        }

        if twitterB.isEqual(sender) {

        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        usernameT?.resignFirstResponder()
        passwordT?.resignFirstResponder()
    }
    
    @IBAction func crashButtonTapped(sender: AnyObject) {
        Crashlytics.sharedInstance().crash()
    }
}
