//
//  ProfileViewController.swift
//  Drone
//
//  Created by Karl Chow on 4/27/16.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import MRProgress
import SwiftyJSON
import BRYXBanner

import RealmSwift

class ProfileViewController:BaseViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    fileprivate final let identifier = "profile_table_view_cell"
    
    @IBOutlet weak var profileTableView: UITableView!
    
    lazy var goal: UserGoal = {
        let userGoal:UserGoal = UserGoal.getAll().first as! UserGoal
        return userGoal
    }()
    
    lazy var profile: UserProfile = {
        var userProfile:UserProfile = UserProfile.getAll().first as! UserProfile
        return userProfile
    }()
    
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

    }

    func save(){
        if NetworkManager.manager.getNetworkState() {
            if !AppDelegate.getAppDelegate().isConnected() {
                let view = MRProgressOverlayView.showOverlayAdded(to: self.navigationController!.view, title: NSLocalizedString("no_watch_connected", comment: ""), mode: MRProgressOverlayViewMode.cross, animated: true)
                view?.setTintColor(UIColor.getBaseColor())
                Timer.after(0.6.second) {
                    view?.dismiss(true)
                }
                return
            }
            
            _ = dismissKeyboard()
            
            // sync goal to watch
            AppDelegate.getAppDelegate().setGoal()
            
            /**
             *  change profile to database sync profile with watch
             *
             */
            AppDelegate.getAppDelegate().setUserProfile()
            
            
            loadingIndicator = MRProgressOverlayView.showOverlayAdded(to: self.navigationController!.view, title: "Please wait...", mode: MRProgressOverlayViewMode.indeterminate, animated: true)
            loadingIndicator.setTintColor(UIColor.getBaseColor())
            
            UserNetworkManager.updateUser(profile: profile, completion: { (success, optionalProfile) in
                if success, let _ = optionalProfile {
                    self.loadingIndicator.dismiss(true, completion: { 
                        self.dismiss(animated: true)
                    })
                }else{
                    debugPrint("Could not update profile.");
                    self.loadingIndicator.dismiss(true)
                    let banner:Banner = Banner(title: NSLocalizedString("not_update", comment: ""), subtitle: "", image: nil, backgroundColor: UIColor.getBaseColor(), didTapBlock: nil)
                    banner.dismissesOnTap = true
                    banner.show(duration: 2)
                }
            })
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
        let cell: ProfileTableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! ProfileTableViewCell
        if(indexPath.row == 0){
            cell.backgroundColor = UIColor("#DCDCDC")
            cell.itemTextField.placeholder = "First Name"
            let firstName:String = profile.first_name
            cell.itemTextField!.text = firstName
            cell.setType(.text)
        }else if(indexPath.row == 1){
            cell.itemTextField.placeholder = "Last Name"
            let last_name:String = profile.last_name
            cell.itemTextField!.text = last_name
            cell.setType(.text)
        }else if(indexPath.row == 2){
            cell.itemTextField.placeholder = "Email"
            let email:String = profile.email
            cell.itemTextField!.text = email
            cell.setType(.email)
            NSLog("profile.email:\(email)")
        }else  if(indexPath.row == 3){
            cell.itemTextField.placeholder = "Length"
            let length:Int = profile.length
            cell.itemTextField!.text = "\(length.to2String()) CM"
            cell.setInputVariables(self.generatePickerData(100, rangeEnd: 250, interval: 0))
            cell.setType(.numeric)
            cell.textPostFix = " CM"
        }else  if(indexPath.row == 4){
            cell.itemTextField.placeholder = "Weight"
            let weight:Int = profile.weight
            cell.itemTextField!.text = "\(weight.to2String()) KG"
            cell.setInputVariables(self.generatePickerData(35, rangeEnd: 150, interval: 0))
            cell.setType(.numeric)
            cell.textPostFix = " KG"
        }else  if(indexPath.row == 5){
            cell.itemTextField.placeholder = "Goal: "
            cell.itemTextField!.text = "Goal: \(String(goal.goalSteps))"
            cell.setInputVariables(self.generatePickerData(1000, rangeEnd: 20000, interval: 1000))
            cell.setType(.numeric)
            cell.textPreFix = "Goal: "
        }else if(indexPath.row == 6) {
            cell.itemTextField.placeholder = "Birthday: "
            let birthday:String = profile.birthday
            cell.itemTextField!.text = "Birthday: \(birthday)"
            cell.setType(.date)
            cell.textPreFix = "Birthday: "
        }
        
        cell.cellIndex = indexPath.row
        cell.editCellTextField = {
            (index,text) -> Void in
            debugPrint("Profile TextField\(index)")
            let relam = try! Realm()
            try! relam.write({
                switch index {
                case 0:
                    self.profile.first_name = text
                case 1:
                    self.profile.last_name = text
                case 2:
                    self.profile.email = text
                case 3:
                    if Int(text) != nil {
                        self.profile.length = text.toInt()
                    }
                case 4:
                    if Int(text) != nil {
                        self.profile.weight = text.toInt()
                    }
                case 5:
                    if Int(text) != nil {
                        self.goal.goalSteps = text.toInt()
                    }
                case 6:
                    self.profile.birthday = text
                default:
                    break
                }
            })
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
