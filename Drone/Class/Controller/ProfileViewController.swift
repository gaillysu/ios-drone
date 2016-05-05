//
//  ProfileViewController.swift
//  Drone
//
//  Created by Karl Chow on 4/27/16.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import AutocompleteField

class ProfileViewController:BaseViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    private final let identifier = "profile_table_view_cell"
    private var profile:UserProfile!
    private var steps:GoalModel!
    @IBOutlet weak var profileTableView: UITableView!
    private var firstNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        profileTableView.registerNib(UINib(nibName: "ProfileTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: identifier)
        let header:ProfileTableViewCellHeader = UIView.loadFromNibNamed("ProfileTableViewCellHeader") as! ProfileTableViewCellHeader;
        firstNameTextField = header.nameTextField
        let headerView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, header.frame.height))
        headerView.addSubview(header)
        self.profileTableView.tableHeaderView = headerView;
        self.navigationItem.title="Profile"
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        let closeButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(close))
        let saveButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(save))
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationItem.leftBarButtonItem = closeButton
        self.navigationItem.rightBarButtonItem = saveButton
        self.profileTableView.allowsSelection  = false;
        self.profileTableView.tableFooterView = UIView()
        profile = UserProfile.getAll()[0] as! UserProfile;
        steps = (GoalModel.getAll()[0] as! GoalModel)
    }
    
    func save(){
        dismissKeyboard()
        guard let firstName = firstNameTextField.text where !firstName.isEmpty else {
            return;
        }
        for i in 0...4 {
            let cell: ProfileTableViewCell = profileTableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0)) as! ProfileTableViewCell
            guard var text = cell.itemTextField.text where !text.isEmpty else {
                return;
            }
            if i == 0{
             profile.last_name = text
            } else if i == 1 {
             profile.email = text
            } else if i == 2 {
            text = text.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet).joinWithSeparator("")
             profile.lenght = Int(text)!
            } else if i == 3 {
            text = text.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet).joinWithSeparator("")
             profile.weight = Int(text)!
            } else if i == 4 {
                text = text.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet).joinWithSeparator("")
                steps = (GoalModel.getAll()[0] as! GoalModel)
                steps.goalSteps = Int(text)!
                steps.update()
            }
        }
        profile.update()
    }
    
    func close(){
        dismissKeyboard()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: ProfileTableViewCell = tableView.dequeueReusableCellWithIdentifier(identifier) as! ProfileTableViewCell
        if(indexPath.row == 0){
            cell.itemTextField!.text = profile.last_name
            cell.setType(.Text)
        }else if(indexPath.row == 1){
            cell.itemTextField!.text = profile.email
            cell.setType(.Email)
        }else  if(indexPath.row == 2){
            cell.itemTextField!.text = "\(String(profile.lenght)) CM"
            cell.setInputVariables(self.generatePickerData(100, rangeEnd: 220, interval: 0))
            cell.setType(.Numeric)
            cell.textPostFix = " CM"
        }else  if(indexPath.row == 3){
            cell.itemTextField!.text = "\(String(profile.weight)) KG"
            cell.setInputVariables(self.generatePickerData(10, rangeEnd: 200, interval: 0))
            cell.setType(.Numeric)
            cell.textPostFix = " KG"
        }else  if(indexPath.row == 4){
            cell.itemTextField!.text = "Goal: \(String(steps.goalSteps))"
            cell.setInputVariables(self.generatePickerData(1000, rangeEnd: 20000, interval: 1000))
            cell.setType(.Numeric)
            cell.textPreFix = "Goal: "
        }
        return cell;
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
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