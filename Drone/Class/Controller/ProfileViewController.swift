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
    
    fileprivate final let identifier = "profile_table_view_cell"
    fileprivate var profile:UserProfile!
    fileprivate var steps:UserGoal!
    @IBOutlet weak var profileTableView: UITableView!
    var loadingIndicator: MRProgressOverlayView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        profileTableView.register(UINib(nibName: "ProfileTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: identifier)
        self.navigationItem.title="Profile"
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        let closeButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close))
        let saveButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = closeButton
        self.navigationItem.rightBarButtonItem = saveButton
        self.profileTableView.allowsSelection  = false;
        profile = UserProfile.getAll()[0] as! UserProfile;
        steps = UserGoal.getAll()[0] as! UserGoal
    }

    func save(){
        if AppDelegate.getAppDelegate().network!.isReachable {
            if !AppDelegate.getAppDelegate().isConnected() {
                let view = MRProgressOverlayView.showOverlayAdded(to: self.navigationController!.view, title: NSLocalizedString("no_watch_connected", comment: ""), mode: MRProgressOverlayViewMode.cross, animated: true)
                view?.setTintColor(UIColor.getBaseColor())
                Timer.after(0.6.second) {
                    view?.dismiss(true)
                }
                return
            }
            
            _ = dismissKeyboard()
            
            /**
             *  update goal
             *
             */
            _ = steps.update()
            
            /**
             *  change profile to database
             *
             */
            _ = profile.update()
            
            AppDelegate.getAppDelegate().setGoal(NumberOfStepsGoal(steps: steps.goalSteps))
            let timerout:Timer = Timer.after(5.seconds) {
                /**
                 *  change profile to database sync profile with watch
                 *
                 */
                AppDelegate.getAppDelegate().setUserProfile()
            }
            
            AppDelegate.getAppDelegate().sendIndex = {
                (index) -> Void in
                timerout.invalidate()
                AppDelegate.getAppDelegate().log.debug("send set goal")
                /**
                 *  change profile to database sync profile with watch
                 *
                 */
                AppDelegate.getAppDelegate().setUserProfile()
            }
            
            
            loadingIndicator = MRProgressOverlayView.showOverlayAdded(to: self.navigationController!.view, title: "Please wait...", mode: MRProgressOverlayViewMode.indeterminate, animated: true)
            loadingIndicator.setTintColor(UIColor.getBaseColor())
            
            HttpPostRequest.putRequest("http://drone.karljohnchow.com/user/update", data: ["user":["id":profile.id, "first_name":profile.first_name,"last_name":profile.last_name,"email":profile.email,"length":profile.length,"birthday":profile.birthday,"weight":profile.weight] as AnyObject]) { (result) in
                let json = JSON(result)
                let status = json["status"].intValue
                let user:[String : JSON] = json["user"].dictionaryValue
                if(status > 0 && user.count > 0) {
                    self.loadingIndicator.dismiss(true, completion: {
                        self.dismiss(animated: true, completion: nil)
                    })
                }else{
                    XCGLogger.debug("Request error");
                    self.loadingIndicator.dismiss(true)
                    let banner:Banner = Banner(title: NSLocalizedString("not_update", comment: ""), subtitle: "", image: nil, backgroundColor: UIColor.getBaseColor(), didTapBlock: nil)
                    banner.dismissesOnTap = true
                    banner.show(duration: 3)
                }
            }
        }else{
            let view = MRProgressOverlayView.showOverlayAdded(to: self.navigationController!.view, title: "No internet", mode: MRProgressOverlayViewMode.cross, animated: true)
            view?.setTintColor(UIColor.getBaseColor())
            let _:Timer = Timer.after(0.6.seconds, {
                MRProgressOverlayView.dismissAllOverlays(for: self.navigationController!.view, animated: true)
            })
        }
    }
    
    func close(){
        dismissKeyboard()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func logoutAction(_ sender: AnyObject) {
        let logout:UIAlertController = UIAlertController(title: NSLocalizedString("logout_title", comment: "") , message: NSLocalizedString("logout_message", comment: "") , preferredStyle: UIAlertControllerStyle.alert)
        logout.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: UIAlertActionStyle.default, handler: { (action) in
            if(self.profile.remove()){
                _ = UserSteps.removeAll()
                AppDelegate.getAppDelegate().disconnect()
                self.dismiss(animated: true, completion: nil)
            }
        }))
        
        logout.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: UIAlertActionStyle.cancel, handler: { (action) in
            
        }))
        self.present(logout, animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 1 {
            self.dismiss(animated: true, completion: nil)
            _ = UserProfile.removeAll()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).row == 0 {
            let header:ProfileTableViewCellHeader = UIView.loadFromNibNamed("ProfileTableViewCellHeader") as! ProfileTableViewCellHeader;
            return header.frame.height
        }else{
            let profileCell:ProfileTableViewCell = UIView.loadFromNibNamed("ProfileTableViewCell") as! ProfileTableViewCell
            return profileCell.frame.height
        }
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ProfileTableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier) as! ProfileTableViewCell
        
        if((indexPath as NSIndexPath).row == 0){
            cell.backgroundColor = UIColor(rgba: "#DCDCDC")
            cell.itemTextField.placeholder = "First Name"
            cell.itemTextField!.text = profile.first_name
            cell.setType(.text)
        }else if((indexPath as NSIndexPath).row == 1){
            cell.itemTextField.placeholder = "Last Name"
            cell.itemTextField!.text = profile.last_name
            cell.setType(.text)
        }else if((indexPath as NSIndexPath).row == 2){
            cell.itemTextField.placeholder = "Email"
            cell.itemTextField!.text = profile.email
            cell.setType(.email)
        }else  if((indexPath as NSIndexPath).row == 3){
            cell.itemTextField.placeholder = "Length"
            cell.itemTextField!.text = "\(String(profile.length)) CM"
            cell.setInputVariables(self.generatePickerData(100, rangeEnd: 250, interval: 0))
            cell.setType(.numeric)
            cell.textPostFix = " CM"
        }else  if((indexPath as NSIndexPath).row == 4){
            cell.itemTextField.placeholder = "Weight"
            cell.itemTextField!.text = "\(String(profile.weight)) KG"
            cell.setInputVariables(self.generatePickerData(35, rangeEnd: 150, interval: 0))
            cell.setType(.numeric)
            cell.textPostFix = " KG"
        }else  if((indexPath as NSIndexPath).row == 5){
            cell.itemTextField.placeholder = "Goal: "
            cell.itemTextField!.text = "Goal: \(String(steps.goalSteps))"
            cell.setInputVariables(self.generatePickerData(1000, rangeEnd: 20000, interval: 1000))
            cell.setType(.numeric)
            cell.textPreFix = "Goal: "
        }else if((indexPath as NSIndexPath).row == 6) {
            cell.itemTextField.placeholder = "Birthday: "
            cell.itemTextField!.text = "Birthday: \(profile.birthday)"
            cell.setType(.date)
            cell.textPreFix = "Birthday: "
        }
        
        cell.cellIndex = (indexPath as NSIndexPath).row
        cell.editCellTextField = {
            (index,text) -> Void in
            XCGLogger.debug("Profile TextField\(index)")
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
            case 6:
                self.profile.birthday = text
            default:
                break
            }
        }
        
        return cell;
    }
    
    fileprivate func generatePickerData(_ rangeBegin: Int,rangeEnd: Int, interval: Int)->NSMutableArray{
        let data:NSMutableArray = NSMutableArray();
        for i in rangeBegin...rangeEnd{
            if(interval > 0){
                if i % interval == 0 {
                    data.add("\(i)")
                }
            }else{
                data.add("\(i)")
            }
        }
        return data;
    }
}
