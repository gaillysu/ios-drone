//
//  ProfileViewController.swift
//  Drone
//
//  Created by Karl Chow on 4/27/16.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import AutocompleteField
import MRProgress
import SwiftyJSON
import BRYXBanner
import XCGLogger

class ProfileViewController:BaseViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    private final let identifier = "profile_table_view_cell"
    private var profile:UserProfile!
    private var steps:UserGoal!
    @IBOutlet weak var profileTableView: UITableView!
    var loadingIndicator: MRProgressOverlayView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        profileTableView.registerNib(UINib(nibName: "ProfileTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: identifier)
        self.navigationItem.title="Profile"
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        let closeButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(close))
        let saveButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(save))
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationItem.leftBarButtonItem = closeButton
        self.navigationItem.rightBarButtonItem = saveButton
        self.profileTableView.allowsSelection  = false;
        profile = UserProfile.getAll()[0] as! UserProfile;
        steps = UserGoal.getAll()[0] as! UserGoal
    }
    
    
    func someSelector() {
        
    }

    
    func save(){
        if !AppDelegate.getAppDelegate().isConnected() {
            let view = MRProgressOverlayView.showOverlayAddedTo(self.navigationController!.view, title: NSLocalizedString("no_watch_connected", comment: ""), mode: MRProgressOverlayViewMode.Cross, animated: true)
            view.setTintColor(UIColor.getBaseColor())
            NSTimer.after(0.6.second) {
                view.dismiss(true)
            }
            return
        }
        
        dismissKeyboard()
        
        profile.update()
        
        loadingIndicator = MRProgressOverlayView.showOverlayAddedTo(self.navigationController!.view, title: "Please wait...", mode: MRProgressOverlayViewMode.Indeterminate, animated: true)
        loadingIndicator.setTintColor(UIColor.getBaseColor())
        
        HttpPostRequest.putRequest("http://drone.karljohnchow.com/user/update", data: ["user":["id":profile.id, "first_name":profile.first_name,"last_name":profile.last_name,"email":profile.email,"length":profile.length]]) { (result) in
            let json = JSON(result)
            let message = json["message"].stringValue
            let status = json["status"].intValue
            let user:[String : JSON] = json["user"].dictionaryValue
            if(status > 0) {
                self.loadingIndicator.mode = MRProgressOverlayViewMode.Checkmark
                MRProgressOverlayView.dismissAllOverlaysForView(self.navigationController!.view, animated: true)
                self.dismissViewControllerAnimated(true, completion: nil)
            }else{
                print("Request error");
                self.loadingIndicator.mode = MRProgressOverlayViewMode.Checkmark
                MRProgressOverlayView.dismissAllOverlaysForView(self.navigationController!.view, animated: true)
                let banner:Banner = Banner(title: "Update request error", subtitle: "", image: nil, backgroundColor: UIColor.redColor(), didTapBlock: nil)
                banner.show()
            }
        }
        
    }
    
    func close(){
        dismissKeyboard()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func logoutAction(sender: AnyObject) {
        let logout:UIAlertController = UIAlertController(title: NSLocalizedString("logout_title", comment: "") , message: NSLocalizedString("logout_message", comment: "") , preferredStyle: UIAlertControllerStyle.Alert)
        logout.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: UIAlertActionStyle.Default, handler: { (action) in
            if(self.profile.remove()){
                AppDelegate.getAppDelegate().disconnect()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }))
        
        logout.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: UIAlertActionStyle.Cancel, handler: { (action) in
            
        }))
        self.presentViewController(logout, animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            self.dismissViewControllerAnimated(true, completion: nil)
            UserProfile.removeAll()
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            let header:ProfileTableViewCellHeader = UIView.loadFromNibNamed("ProfileTableViewCellHeader") as! ProfileTableViewCellHeader;
            return header.frame.height
        }else{
            let profileCell:ProfileTableViewCell = UIView.loadFromNibNamed("ProfileTableViewCell") as! ProfileTableViewCell
            return profileCell.frame.height
        }
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: ProfileTableViewCell = tableView.dequeueReusableCellWithIdentifier(identifier) as! ProfileTableViewCell
        
        if(indexPath.row == 0){
            cell.backgroundColor = UIColor(rgba: "#DCDCDC")
            cell.itemTextField.placeholder = "First Name"
            cell.itemTextField!.text = profile.first_name
            cell.setType(.Text)
        }else if(indexPath.row == 1){
            cell.itemTextField.placeholder = "Last Name"
            cell.itemTextField!.text = profile.last_name
            cell.setType(.Text)
        }else if(indexPath.row == 2){
            cell.itemTextField.placeholder = "Email"
            cell.itemTextField!.text = profile.email
            cell.setType(.Email)
        }else  if(indexPath.row == 3){
            cell.itemTextField.placeholder = "Length"
            cell.itemTextField!.text = "\(String(profile.length)) CM"
            cell.setInputVariables(self.generatePickerData(100, rangeEnd: 220, interval: 0))
            cell.setType(.Numeric)
            cell.textPostFix = " CM"
        }else  if(indexPath.row == 4){
            cell.itemTextField.placeholder = "Weight"
            cell.itemTextField!.text = "\(String(profile.weight)) KG"
            cell.setInputVariables(self.generatePickerData(10, rangeEnd: 200, interval: 0))
            cell.setType(.Numeric)
            cell.textPostFix = " KG"
        }else  if(indexPath.row == 5){
            cell.itemTextField.placeholder = "Goal: "
            cell.itemTextField!.text = "Goal: \(String(steps.goalSteps))"
            cell.setInputVariables(self.generatePickerData(1000, rangeEnd: 20000, interval: 1000))
            cell.setType(.Numeric)
            cell.textPreFix = "Goal: "
        }
        
        cell.cellIndex = indexPath.row
        cell.editCellTextField = {
            (index,text) -> Void in
            XCGLogger.defaultInstance().debug("Profile TextField\(index)")
            switch index {
            case 0:
                self.profile.first_name = text
            case 1:
                self.profile.last_name = text
            case 2:
                self.profile.email = text
            case 3:
                if Int(text) != nil {
                    self.profile.length = Int(text)!
                }
            case 4:
                if Int(text) != nil {
                    self.profile.weight = Int(text)!
                }
            case 5:
                if Int(text) != nil {
                    self.steps.goalSteps = Int(text)!
                }
            default:
                break
            }
        }
        
        return cell;
    }
    
    private func generatePickerData(rangeBegin: Int,rangeEnd: Int, interval: Int)->NSMutableArray{
        let data:NSMutableArray = NSMutableArray();
        for i in rangeBegin...rangeEnd{
            if(interval > 0){
                if i % interval == 0 {
                    data.addObject("\(i)")
                }
            }else{
                data.addObject("\(i)")
            }
        }
        return data;
    }
}