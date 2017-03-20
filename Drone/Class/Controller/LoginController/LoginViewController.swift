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
import BRYXBanner
import UIColor_Hex_Swift
import SwiftyJSON
import MRProgress


class LoginViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var textfiledBG: UIView!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    var usernameT: AutocompleteField?
    var passwordT: AutocompleteField?
    var fromMenu:Bool = false;
    init(fromMenu: Bool = false) {
        self.fromMenu = fromMenu
        super.init(nibName: "LoginViewController", bundle: Bundle.main)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        if (usernameT == nil) {
            usernameT = AutocompleteField(frame: CGRect(x: 0, y: 0, width: textfiledBG.frame.size.width, height: textfiledBG.frame.size.height/2.0-0.5))
            usernameT!.padding = 15.0
            usernameT?.font = UIFont(name: usernameT!.font!.fontName, size: 15);
            usernameT!.placeholder = "E-mail"
            usernameT?.backgroundColor = UIColor.white
//            usernameT?.text = "test@user.com"
            
            textfiledBG.addSubview(usernameT!)

            passwordT = AutocompleteField(frame: CGRect(x: 0, y: textfiledBG.frame.size.height/2.0, width: textfiledBG.frame.size.width, height: textfiledBG.frame.size.height/2.0-0.5))
            passwordT?.isSecureTextEntry = true
            passwordT!.padding = 15.0
            passwordT?.font = UIFont(name: usernameT!.font!.fontName, size: 15);
            passwordT!.placeholder = "Password"
            passwordT?.backgroundColor = UIColor.white
//            passwordT?.text = "12341234"
            textfiledBG.addSubview(passwordT!)
        }
    }

    @IBAction func buttonActionManager(_ sender: AnyObject) {
        if backButton.isEqual(sender) {
            _ = self.navigationController?.popViewController(animated: true)
        }

        if loginButton.isEqual(sender) {
            loginRequest()
        }

        if googleButton.isEqual(sender) {

        }

        if facebookButton.isEqual(sender) {

        }

        if twitterButton.isEqual(sender) {

        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        usernameT?.resignFirstResponder()
        passwordT?.resignFirstResponder()
    }

    func loginRequest() {
        if AppDelegate.getAppDelegate().network!.isReachable {
            if(AppTheme.isNull(usernameT!.text!) || !AppTheme.isEmail(usernameT!.text!)) {
                let banner = Banner(title: NSLocalizedString("Email is not filled in.", comment: ""), subtitle: nil, image: nil, backgroundColor:UIColor.getBaseColor())
                banner.dismissesOnTap = true
                banner.show(duration: 1.2)
                return
            }
            
            if AppTheme.isNull(passwordT!.text!) || AppTheme.isPassword(passwordT!.text!) {
                let banner = Banner(title: NSLocalizedString("Password is not filled in.", comment: ""), subtitle: nil, image: nil, backgroundColor:UIColor.getBaseColor())
                banner.dismissesOnTap = true
                banner.show(duration: 1.2)
                return
            }
            
            let view = MRProgressOverlayView.showOverlayAdded(to: self.navigationController!.view, title: "Please wait...", mode: MRProgressOverlayViewMode.indeterminate, animated: true)
            view?.setTintColor(UIColor.getBaseColor())
            let timeout:Timer = Timer.after(90.seconds, {
                MRProgressOverlayView.dismissAllOverlays(for: self.navigationController!.view, animated: true)
            })
            
            UserNetworkManager.login(email: usernameT!.text!, password: passwordT!.text!, completion: { (success, profile) in
                timeout.invalidate()
                MRProgressOverlayView.dismissAllOverlays(for: self.navigationController!.view, animated: true)
                
                if success, let unpackedProfile = profile{
                    let banner = Banner(title: NSLocalizedString(NSLocalizedString("logged_in", comment: ""), comment: ""), subtitle: nil, image: nil, backgroundColor: success ? UIColor.getBaseColor():UIColor.getBaseColor())
                    banner.dismissesOnTap = true
                    banner.show(duration: 1.2)
                    StepsNetworkManager.stepsForPeriod(uid: unpackedProfile.id, startDate: Date(), endDate: (Date() - 30.days), completion: { result in
                        print("results = \(result.requestSuccess)")
                        print("results = \(result.databaseSaved)")
                        debugPrint("Synced Steps with the Cloud!")
                    })
                    
                    if self.fromMenu{
                        self.navigationController?.dismiss(animated: true, completion: nil)
                    }else{
                        let device:WhichDeviceViewController = WhichDeviceViewController(toMenu: true)
                        self.navigationController?.pushViewController(device, animated: true)
                    }
                }else{
                    let banner = Banner(title: NSLocalizedString(NSLocalizedString("not_login", comment: ""), comment: ""), subtitle: nil, image: nil, backgroundColor: success ? UIColor.getBaseColor():UIColor.getBaseColor())
                    banner.dismissesOnTap = true
                    banner.show(duration: 1.2)
                    
                }
            })
            
            if(UserGoal.getAll().count == 0){
                let goal:UserGoal = UserGoal()
                goal.goalSteps = 10000
                goal.label = " "
                goal.status = false
                _ = goal.add()
            }
        }else{
            let view = MRProgressOverlayView.showOverlayAdded(to: self.navigationController!.view, title: "No internet", mode: MRProgressOverlayViewMode.cross, animated: true)
            view?.setTintColor(UIColor.getBaseColor())
            Timer.after(0.6.seconds, {
                MRProgressOverlayView.dismissAllOverlays(for: self.navigationController!.view, animated: true)
            })
        }
        
    }
}
