//
//  ProfileViewController.swift
//  Drone
//
//  Created by Karl Chow on 4/27/16.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation

class ProfileViewController:BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    private final let identifier = "profile_table_view_cell"
    
    @IBOutlet weak var profileTableView: UITableView!
    
    override func viewDidLoad() {
        profileTableView.registerNib(UINib(nibName: "ProfileTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: identifier)
        let header:UIView = UIView.loadFromNibNamed("ProfileTableViewCellHeader")!;
        
        
        self.profileTableView.tableHeaderView = header
        print(header.frame.height)
        self.navigationItem.title="Profile"
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        let closeButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(close))
        let saveButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(save))
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationItem.leftBarButtonItem = closeButton;
        self.navigationItem.rightBarButtonItem = saveButton;
    }
    
    func save(){
        
    }
    
    func close(){
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
            cell.textLabel!.text = "Doe"
        }else if(indexPath.row == 1){
            cell.textLabel!.text = "john@doe.com"
        }else  if(indexPath.row == 2){
            cell.textLabel!.text = "170 CM"
        }else  if(indexPath.row == 3){
            cell.textLabel!.text = "70 KG"
        }else  if(indexPath.row == 4){
            cell.textLabel!.text = "Goal: 10000"
        }
        cell.separatorInset = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsZero
        return cell;
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
}