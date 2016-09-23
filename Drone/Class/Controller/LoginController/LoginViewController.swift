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
import XCGLogger

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
            textfiledBG.addSubview(usernameT!)

            passwordT = AutocompleteField(frame: CGRect(x: 0, y: textfiledBG.frame.size.height/2.0, width: textfiledBG.frame.size.width, height: textfiledBG.frame.size.height/2.0-0.5))
            passwordT?.isSecureTextEntry = true
            passwordT!.padding = 15.0
            passwordT?.font = UIFont(name: usernameT!.font!.fontName, size: 15);
            passwordT!.placeholder = "Password"
            passwordT?.backgroundColor = UIColor.white
            textfiledBG.addSubview(passwordT!)
        }

    }

    @IBAction func buttonActionManager(_ sender: AnyObject) {
        if backButton.isEqual(sender) {
            self.navigationController?.popViewController(animated: true)
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
            XCGLogger.debug("有网络")
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
            
            HttpPostRequest.postRequest("http://drone.karljohnchow.com/user/login", data: ["user":["email":usernameT!.text!,"password":passwordT!.text!]]) { (result) in
                timeout.invalidate()
                MRProgressOverlayView.dismissAllOverlays(for: self.navigationController!.view, animated: true)
                
                let json = JSON(result)
                let message = json["message"].stringValue.isEmpty ? NSLocalizedString("not_login", comment: ""):json["message"].stringValue
                let status = json["status"].intValue
                
                let banner = Banner(title: NSLocalizedString(message, comment: ""), subtitle: nil, image: nil, backgroundColor: status > 0 ? UIColor.getBaseColor():UIColor.getBaseColor())
                banner.dismissesOnTap = true
                banner.show(duration: 1.2)
                
                //status > 0 login success or login fail
                if(status > 0 && UserProfile.getAll().count == 0) {
                    let user = json["user"]
                    let jsonBirthday = user["birthday"];
                    let dateString: String = jsonBirthday["date"].stringValue
                    var birthday:String = ""
                    if !jsonBirthday.isEmpty || !dateString.isEmpty {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "y-M-d h:m:s.000000"
                        
                        let birthdayDate = dateFormatter.date(from: dateString)
                        dateFormatter.dateFormat = "y-M-d"
                        birthday = dateFormatter.string(from: birthdayDate!)
                    }
                    
                    let userprofile:UserProfile = UserProfile(keyDict: ["id":user["id"].intValue,"first_name":user["first_name"].stringValue,"last_name":user["last_name"].stringValue,"birthday":birthday,"length":user["length"].intValue,"email":user["email"].stringValue, "weight":user["weight"].floatValue])
                    userprofile.add({ (id, completion) in
                        XCGLogger.debug("Added? id = \(id)")
                    })
                    if(UserGoal.getAll().count == 0){
                        let goal:UserGoal = UserGoal(keyDict: ["goalSteps":10000,"label":" ","status":false])
                        goal.add({ (id, completion) in})
                    }
                    
                }
                if(status == 1){
                    let startDate = Date(timeIntervalSince1970: Date().timeIntervalSince1970-(86400*30))
                    stepsDownload.getServiceSteps(startDate)
                    if self.fromMenu{
                        self.navigationController?.dismiss(animated: true, completion: nil)
                    }else{
                        let device:WhichDeviceViewController = WhichDeviceViewController(toMenu: true)
                        self.navigationController?.pushViewController(device, animated: true)
                    }
                }
            }
        }else{
            
            XCGLogger.debug("没有网络")
            let view = MRProgressOverlayView.showOverlayAdded(to: self.navigationController!.view, title: "No internet", mode: MRProgressOverlayViewMode.cross, animated: true)
            view?.setTintColor(UIColor.getBaseColor())
            Timer.after(0.6.seconds, {
                MRProgressOverlayView.dismissAllOverlays(for: self.navigationController!.view, animated: true)
            })
        }
        
    }
}
