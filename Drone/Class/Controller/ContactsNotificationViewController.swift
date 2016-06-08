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
import MRProgress
import SwiftyTimer
import BRYXBanner
import MSCellAccessory


class ContactsNotificationViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, ABPeoplePickerNavigationControllerDelegate {
    @IBOutlet var tableView: UITableView!
    let peoplePicker:ABPeoplePickerNavigationController = ABPeoplePickerNavigationController()
    let addressBookRef: ABAddressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
    var contactsFilterArray:NSArray = ["Go to your notifications!","Go to your blocked callers!"]
        //ContactsFilter.getAll()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Notifications"
        self.navigationController!.navigationBar.topItem!.title = "";
//        let button: UIButton = UIButton(type: UIButtonType.Custom)
//        button.setImage(UIImage(named: "addbutton"), forState: UIControlState.Normal)
//        button.addTarget(self, action: #selector(add), forControlEvents: UIControlEvents.TouchUpInside)
//        button.frame = CGRectMake(0, 0, 30, 30)
//        let barButton = UIBarButtonItem(customView: button)
//        self.navigationItem.rightBarButtonItem = barButton
        
        self.tableView.separatorColor = UIColor.clearColor()
        self.tableView.rowHeight = 60.0
        
        let header:UIView = UIView.loadFromNibNamed("ContactsNotificationHeader")!
        header.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, header.frame.height)
        let headerView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, header.frame.height))
        headerView.addSubview(header)
        self.tableView.tableHeaderView = headerView

        peoplePicker.peoplePickerDelegate = self;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }
    
    func add(){
        if AppDelegate.getAppDelegate().isConnected() {
            if contactsFilterArray.count == 15 {
                let banner = Banner(title: NSLocalizedString("A maximum of 15 contacts can be added.", comment: ""), subtitle: nil, image: nil, backgroundColor: UIColor.getBaseColor())
                banner.dismissesOnTap = true
                banner.show(duration: 1.2)
                return
            }
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
        }else{
            
            let view = MRProgressOverlayView.showOverlayAddedTo(self.navigationController!.view, title: NSLocalizedString("no_watch_connected", comment: ""), mode: MRProgressOverlayViewMode.Cross, animated: true)
            view.setTintColor(UIColor.getBaseColor())
            NSTimer.after(0.6.second) {
                view.dismiss(true)
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactsFilterArray.count
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
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
            if self.contactsFilterArray.count == 0 {
                let request:SetContactsFilterRequest = SetContactsFilterRequest(contactsMode: 1, appNameMode: 1)
                AppDelegate.getAppDelegate().sendContactsRequest(request,index: 0)
                AppDelegate.getAppDelegate().sendIndex = {
                    (index) -> Void in
                    AppDelegate.getAppDelegate().log.debug("send Contacts\(index)")
                }
            }else{
                let request:UpdateContactsFilterRequest = UpdateContactsFilterRequest(contact: contactsFilter.name, operation: 2, contactID: 0)
                let requestArray:[Request] = [request]
                AppDelegate.getAppDelegate().sendContactsRequest(request,index: 0)
                AppDelegate.getAppDelegate().sendIndex = {
                    (index) -> Void in
                    if(index != requestArray.count ) {
                        AppDelegate.getAppDelegate().log.debug("send Contacts\(index)")
                        AppDelegate.getAppDelegate().sendContactsRequest(requestArray[index],index: index)
                    }
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("identifier");
        
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "identifier")
            cell?.accessoryView = MSCellAccessory(type: DISCLOSURE_INDICATOR, color: UIColor.getTintColor())
        }
        let contact = contactsFilterArray[indexPath.row] as! String
        cell?.backgroundColor = UIColor.transparent()
        cell?.textLabel?.textColor = UIColor.whiteColor()
        cell?.textLabel?.font = UIFont.systemFontOfSize(20)
        cell?.textLabel?.text = contact
        cell?.separatorInset = UIEdgeInsetsZero
        cell?.preservesSuperviewLayoutMargins = false
        cell?.layoutMargins = UIEdgeInsetsZero
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        var url:NSURL?
        if indexPath.row == 0 {
            url = NSURL(string:"prefs:root=NOTIFICATIONS_ID")
        }else {
            url = NSURL(string:"prefs:root=Phone&path=Blocked")
        }
        
        if UIApplication.sharedApplication().canOpenURL(url!) {
            UIApplication.sharedApplication().openURL(url!)
        }
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
    
        let contact:ContactsFilter = ContactsFilter(keyDict: ["name":name])
        contact.add { (id, completion) in
            if(completion!) {
                let request4:UpdateContactsFilterRequest = UpdateContactsFilterRequest(contact: contact.name, operation: 1, contactID: 3)
                let request5:UpdateContactsApplicationsRequest = UpdateContactsApplicationsRequest(appPackage: "com.apple.MobileSMS", operationMode: 1)
                let request6:UpdateContactsApplicationsRequest = UpdateContactsApplicationsRequest(appPackage: "com.apple.mobilephone", operationMode: 1)
                let request7:UpdateContactsApplicationsRequest = UpdateContactsApplicationsRequest(appPackage: "com.apple.mobilemail", operationMode: 1)
                let requestArray:[Request] = [request4,request5,request6,request7]
                AppDelegate.getAppDelegate().sendContactsRequest(request4,index: 0)
                AppDelegate.getAppDelegate().sendIndex = {
                    (index) -> Void in
                    if(index != requestArray.count ) {
                        AppDelegate.getAppDelegate().log.debug("send Contacts\(index)")
                        AppDelegate.getAppDelegate().sendContactsRequest(requestArray[index],index: index)
                    }
                }
            }
        }
        self.contactsFilterArray = ContactsFilter.getAll()
        self.tableView.reloadData()
    }
}