//
//  ContactsNotificationViewController.swift
//  Drone
//
//  Created by Karl Chow on 5/11/16.
//  Copyright © 2016 Cloud. All rights reserved.
//

import UIKit
import Contacts
import AddressBook
import AddressBookUI


class ContactsNotificationViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, ABPeoplePickerNavigationControllerDelegate {
    @IBOutlet var tableView: UITableView!
    let peoplePicker:ABPeoplePickerNavigationController = ABPeoplePickerNavigationController()
    let addressBookRef: ABAddressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
    var contactsFilterArray:NSArray = ContactsFilter.getAll()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationItem.title = "Notifications"
        self.navigationController!.navigationBar.topItem!.title = "";
        
        let button: UIButton = UIButton(type: UIButtonType.Custom)
        button.setImage(UIImage(named: "addbutton"), forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(add), forControlEvents: UIControlEvents.TouchUpInside)
        button.frame = CGRectMake(0, 0, 30, 30)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
        self.tableView.separatorColor = UIColor.whiteColor()
        peoplePicker.peoplePickerDelegate = self;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }
    
    func add(){
        let authorizationStatus = ABAddressBookGetAuthorizationStatus()
        switch authorizationStatus {
        case .Denied, .Restricted:
            self.displayCantAddContactAlert()
        case .Authorized:
            UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
            self.presentViewController(peoplePicker, animated: true, completion: nil)
        case .NotDetermined:
            self.askForAddressBookAccess();
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactsFilterArray.count
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?{
        let button1 = UITableViewRowAction(style: .Default, title: "Delete", handler: { (action, indexPath) in
            self.tableView(tableView, commitEditingStyle: .Delete, forRowAtIndexPath: indexPath)
        })
        button1.backgroundColor = UIColor.getTintColor()
        return [button1]
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let contactsFilter:ContactsFilter = contactsFilterArray[indexPath.row] as! ContactsFilter
            contactsFilter.remove()

            self.contactsFilterArray = ContactsFilter.getAll();
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            // Delete worldclock at watch
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("identifier");
        
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "identifier")
        }
        let contact = contactsFilterArray[indexPath.row] as! ContactsFilter
        cell?.backgroundColor = UIColor.transparent()
        cell?.textLabel?.textColor = UIColor.whiteColor()
        cell?.textLabel?.text = contact.name
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
    }
    
    func showMessage(message: String) {
        let alertController = UIAlertController(title: "Test", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let dismissAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
        }
        
        alertController.addAction(dismissAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func askForAddressBookAccess() {
        var err: Unmanaged<CFError>? = nil
        ABAddressBookRequestAccessWithCompletion(addressBookRef) {
            (granted: Bool, error: CFError!) in
            dispatch_async(dispatch_get_main_queue()) {
                if !granted {
                    self.displayCantAddContactAlert()
                }
            }
        }
    }
    
    func openSettings() {
        let url = NSURL(string: UIApplicationOpenSettingsURLString)
        UIApplication.sharedApplication().openURL(url!)
    }
    
    func displayCantAddContactAlert() {
        let cantAddContactAlert = UIAlertController(title: "Cannot Add Contact",
                                                    message: "You must give the app permission to add the contact first.",
                                                    preferredStyle: .Alert)
        cantAddContactAlert.addAction(UIAlertAction(title: "Change Settings",
            style: .Default,
            handler: { action in
                self.openSettings()
        }))
        cantAddContactAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        presentViewController(cantAddContactAlert, animated: true, completion: nil)
    }
    
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController, didSelectPerson person: ABRecord) {
        let name = ABRecordCopyCompositeName(person).takeRetainedValue()
        //UpdateContactsApplicationsRequest
        //Messages - com.apple.MobileSMS
        //Phone - com.apple.mobilephone
        //Mail - com.apple.mobilemail
        
        let contact:ContactsFilter = ContactsFilter(keyDict: ["name":name])
        contact.add { (id, completion) in
            if(completion!) {
                let request:UpdateContactsApplicationsRequest = UpdateContactsApplicationsRequest(appPackage: "com.apple.MobileSMS", operationMode: 1)
                let request1:UpdateContactsApplicationsRequest = UpdateContactsApplicationsRequest(appPackage: "com.apple.mobilephone", operationMode: 1)
                let request2:UpdateContactsApplicationsRequest = UpdateContactsApplicationsRequest(appPackage: "com.apple.mobilemail", operationMode: 1)
                AppDelegate.getAppDelegate().sendRequest(request)
            }
        }
        self.contactsFilterArray = ContactsFilter.getAll()
        self.tableView.reloadData()
    }
}