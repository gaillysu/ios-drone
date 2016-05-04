//
//  LoginController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/25.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit
import AutocompleteField
import BRYXBanner
import UIColor_Hex_Swift
import SwiftyJSON
import MRProgress

class LoginController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var textfiledBG: UIView!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
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
        if (usernameT == nil) {
            usernameT = AutocompleteField(frame: CGRectMake(0, 0, textfiledBG.frame.size.width, textfiledBG.frame.size.height/2.0-0.5))
            usernameT!.padding = 15.0
            usernameT?.font = UIFont(name: usernameT!.font!.fontName, size: 15);
            usernameT!.placeholder = "Username"
            usernameT?.backgroundColor = UIColor.whiteColor()
            textfiledBG.addSubview(usernameT!)

            passwordT = AutocompleteField(frame: CGRectMake(0, textfiledBG.frame.size.height/2.0, textfiledBG.frame.size.width, textfiledBG.frame.size.height/2.0-0.5))
            passwordT?.secureTextEntry = true
            passwordT!.padding = 15.0
            passwordT?.font = UIFont(name: usernameT!.font!.fontName, size: 15);
            passwordT!.placeholder = "Password"
            passwordT?.backgroundColor = UIColor.whiteColor()
            textfiledBG.addSubview(passwordT!)
        }

    }

    @IBAction func buttonActionManager(sender: AnyObject) {
        if backButton.isEqual(sender) {
            self.navigationController?.popViewControllerAnimated(true)
        }

        if nextButton.isEqual(sender) {
            self.logoinRequest()
        }

        if googleButton.isEqual(sender) {

        }

        if facebookButton.isEqual(sender) {

        }

        if twitterButton.isEqual(sender) {

        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        usernameT?.resignFirstResponder()
        passwordT?.resignFirstResponder()
    }

    func logoinRequest() {
        if(AppTheme.isNull(usernameT!.text!) || AppTheme.isEmail(usernameT!.text!)) {
            let banner = Banner(title: NSLocalizedString("your username is null or username not is email", comment: ""), subtitle: nil, image: nil, backgroundColor:UIColor.redColor())
            banner.dismissesOnTap = true
            banner.show(duration: 1.2)
            return
        }

        if AppTheme.isNull(passwordT!.text!) || AppTheme.isPassword(passwordT!.text!) {
            let banner = Banner(title: NSLocalizedString("Your password is null, Your password must be at least six figures and cannot be all Numbers", comment: ""), subtitle: nil, image: nil, backgroundColor:UIColor.redColor())
            banner.dismissesOnTap = true
            banner.show(duration: 1.2)
            return
        }

        MRProgressOverlayView.showOverlayAddedTo(self.navigationController!.view, title: "Please wait...", mode: MRProgressOverlayViewMode.Indeterminate, animated: true)

        HttpPostRequest.postRequest("http://drone.karljohnchow.com/user/login", data: ["user":["email":usernameT!.text!,"password":passwordT!.text!]]) { (result) in
            MRProgressOverlayView.dismissAllOverlaysForView(self.navigationController!.view, animated: true)

            let json = JSON(result)
            let message = json["message"].stringValue
            let status = json["status"].intValue

            let banner = Banner(title: NSLocalizedString(message, comment: ""), subtitle: nil, image: nil, backgroundColor: status > 0 ? UIColor.greenColor():UIColor.redColor())
            banner.dismissesOnTap = true
            banner.show(duration: 1.2)

            //status > 0 login success or login fail
            if(status > 0 && UserProfile.getAll().count == 0) {
                let userprofile:UserProfile = UserProfile(keyDict: ["id":json["id"].intValue,"first_name":json["first_name"].stringValue,"last_name":json["last_name"].stringValue,"age":json["age"].intValue,"length":json["length"].intValue,"email":json["email"].stringValue])
                userprofile.add({ (id, completion) in

                })
            }
        }
    }
}
