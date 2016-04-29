//
//  ProfileController.swift
//  Nevo
//
//  Created by leiyuncun on 16/3/2.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import AutocompleteField
import SMSegmentView
import UIColor_Hex_Swift
import YYKeyboardManager
import BRYXBanner
import SwiftyJSON

class ProfileSetupViewController: BaseViewController,SMSegmentViewDelegate,UITextFieldDelegate,YYKeyboardObserver {

    @IBOutlet weak var backB: UIButton!
    @IBOutlet weak var nextB: UIButton!
    @IBOutlet weak var textfiledBG: UIView!
    @IBOutlet weak var ageTextField: AutocompleteField!
    @IBOutlet weak var lengthTextField: AutocompleteField!
    @IBOutlet weak var weightTextField: AutocompleteField!
    @IBOutlet weak var metricsSegment: UIView!
    var selectedTextField:UITextField?

    var segmentView:SMSegmentView?
    private var nameDictionary:Dictionary<String,AnyObject> = ["first_name":"DroneUser","last_name":"User"]
    var account:Dictionary<String,AnyObject> = ["email":"","password":""]

    init() {
        super.init(nibName: "ProfileSetupViewController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        textfiledBG.layer.borderColor = UIColor(rgba: "#6F7179").CGColor
        YYKeyboardManager.defaultManager().addObserver(self)
    }

    override func viewDidLayoutSubviews() {
        if(segmentView == nil) {
            let segmentProperties = ["OnSelectionBackgroundColour": UIColor.getBaseColor(),"OffSelectionBackgroundColour": UIColor.whiteColor(),"OnSelectionTextColour": UIColor.whiteColor(),"OffSelectionTextColour": UIColor(rgba: "#95989a")]

            let segmentFrame = CGRect(x: 0, y: 0, width: metricsSegment.frame.size.width, height: metricsSegment.frame.size.height)
            segmentView = SMSegmentView(frame: segmentFrame, separatorColour: UIColor(white: 0.95, alpha: 0.3), separatorWidth: 1.0, segmentProperties: segmentProperties)

            segmentView!.delegate = self
            segmentView!.layer.borderColor = UIColor(white: 0.85, alpha: 1.0).CGColor
            segmentView!.layer.borderWidth = 1.0

            // Add segments
            segmentView!.addSegmentWithTitle("Male", onSelectionImage: nil, offSelectionImage: nil)
            segmentView!.addSegmentWithTitle("Female", onSelectionImage: nil, offSelectionImage: nil)
            
            metricsSegment.addSubview(segmentView!)
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        ageTextField.resignFirstResponder()
        lengthTextField.resignFirstResponder()
        weightTextField.resignFirstResponder()
    }

    @IBAction func buttonActionManager(sender: AnyObject) {
        if (backB.isEqual(sender)) {
            self.navigationController?.popViewControllerAnimated(true)
        }

        if (nextB.isEqual(sender)) {
            registerRequest()
        }
    }

    // MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(textField: UITextField) {
        selectedTextField = textField
    }

    // MARK: - YYKeyboardObserver
    func keyboardChangedWithTransition(transition: YYKeyboardTransition) {
        UIView.animateWithDuration(transition.animationDuration, delay: 0, options: transition.animationOption, animations: {
            let kbFrame:CGRect = YYKeyboardManager.defaultManager().convertRect(transition.toFrame, toView: self.view)
            let kbY:CGFloat = self.view.frame.origin.y < 0 ? 0:kbFrame.origin.y - UIScreen.mainScreen().bounds.size.height
            self.view.frame = CGRectMake(0, kbY, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
            }) { (finished) in

        }
    }

    // MARK: - SMSegmentViewDelegate
    func segmentView(segmentView: SMBasicSegmentView, didSelectSegmentAtIndex index: Int) {
        debugPrint("Select segment at index: \(index)")
    }

    func registerRequest() {
        if(AppTheme.isNull(ageTextField!.text!) || AppTheme.isEmail(lengthTextField!.text!) || AppTheme.isEmail(weightTextField!.text!)) {
            let banner = Banner(title: NSLocalizedString("age or length weight is null", comment: ""), subtitle: nil, image: nil, backgroundColor:UIColor.redColor())
            banner.dismissesOnTap = true
            banner.show(duration: 0.6)
            return
        }

        let first_name:String = nameDictionary["first_name"] as! String
        let last_name:String = nameDictionary["last_name"] as! String
        let email:String = account["email"] as! String
        let password:String = account["password"] as! String
        HttpPostRequest.postRequest("http://drone.karljohnchow.com/user/create", data: ["user":["first_name":first_name,"last_name":last_name,"email":email,"password":password,"age":ageTextField!.text!,"length":lengthTextField!.text!]]) { (result) in
            let json = JSON(result)
            let message = json["message"].stringValue
            let status = json["status"].intValue
            let user:[String : JSON] = json["user"].dictionaryValue

            let banner = Banner(title: NSLocalizedString(message, comment: ""), subtitle: nil, image: nil, backgroundColor:UIColor.redColor())
            banner.dismissesOnTap = true
            banner.show(duration: 1.2)

            //status > 0 register success or register fail
            if(status > 0 && UserProfile.getAll().count == 0) {
                //save database
                let userprofile:UserProfile = UserProfile(keyDict: ["first_name":user["first_name"]!.stringValue,"last_name":user["last_name"]!.stringValue,"age":user["age"]!.intValue,"length":user["length"]!.intValue,"email":user["email"]!.stringValue])
                userprofile.add({ (id, completion) in

                })
                //TODO:register success push controll
                let maintabbar:WhichDeviceViewController = WhichDeviceViewController()
                self.navigationController?.pushViewController(maintabbar, animated: true)
            }
        }
    }
}