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
import BRYXBanner
import SwiftyJSON


class ProfileViewController: BaseViewController,SMSegmentViewDelegate {

    @IBOutlet weak var backB: UIButton!
    @IBOutlet weak var nextB: UIButton!
    @IBOutlet weak var textfiledBG: UIView!
    @IBOutlet weak var ageTextField: AutocompleteField!
    @IBOutlet weak var lengthTextField: AutocompleteField!
    @IBOutlet weak var weightTextField: AutocompleteField!
    @IBOutlet weak var stridelengthTextField: AutocompleteField!
    @IBOutlet weak var metricsSegment: UIView!

    var segmentView:SMSegmentView?
    private var nameDictionary:Dictionary<String,AnyObject> = ["first_name":"DroneUser","last_name":"User"]
    var account:Dictionary<String,AnyObject> = ["email":"","password":""]

    init() {
        super.init(nibName: "ProfileViewController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        textfiledBG.layer.borderColor = UIColor(rgba: "#6F7179").CGColor
    }

    override func viewDidLayoutSubviews() {
        if(segmentView == nil) {
            let segmentProperties = ["OnSelectionBackgroundColour": UIColor(rgba: "#66cccc"),"OffSelectionBackgroundColour": UIColor.whiteColor(),"OnSelectionTextColour": UIColor.whiteColor(),"OffSelectionTextColour": UIColor(rgba: "#95989a")]

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

    @IBAction func buttonActionManager(sender: AnyObject) {
        if (backB.isEqual(sender)) {
            self.navigationController?.popViewControllerAnimated(true)
        }

        if (nextB.isEqual(sender)) {
            registerRequest()
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        ageTextField.resignFirstResponder()
        lengthTextField.resignFirstResponder()
        weightTextField.resignFirstResponder()
        stridelengthTextField.resignFirstResponder()
    }

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
            }
        }
    }
}