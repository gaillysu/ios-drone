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
        
        self.tableView.separatorColor = UIColor.clear
        self.tableView.rowHeight = 60.0
        
        let header:UIView = UIView.loadFromNibNamed("ContactsNotificationHeader")!
        header.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: header.frame.height)
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: header.frame.height))
        headerView.addSubview(header)
        self.tableView.tableHeaderView = headerView

        peoplePicker.peoplePickerDelegate = self;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
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
            case .denied, .restricted:
                self.displayCantAddContactAlert()
            case .authorized:
                UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
                self.present(peoplePicker, animated: true, completion: nil)
            case .notDetermined:
                self.askForAddressBookAccess();
            }
        }else{
            
            let view = MRProgressOverlayView.showOverlayAdded(to: self.navigationController!.view, title: NSLocalizedString("no_watch_connected", comment: ""), mode: MRProgressOverlayViewMode.cross, animated: true)
            view?.setTintColor(UIColor.getBaseColor())
            Timer.after(0.6.second) {
                view?.dismiss(true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactsFilterArray.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?{
        let button1 = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
            self.tableView(tableView, commit: .delete, forRowAt: indexPath)
        })
        button1.backgroundColor = UIColor.getTintColor()
        return [button1]
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let contactsFilter:ContactsFilter = contactsFilterArray[(indexPath as NSIndexPath).row] as! ContactsFilter
            _ = contactsFilter.remove()

            self.contactsFilterArray = ContactsFilter.getAll();
            
            tableView.deleteRows(at: [indexPath], with: .fade)
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "identifier");
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "identifier")
            cell?.accessoryView = MSCellAccessory(type: DISCLOSURE_INDICATOR, color: UIColor.getTintColor())
        }
        let contact = contactsFilterArray[(indexPath as NSIndexPath).row] as! String
        cell?.backgroundColor = UIColor.transparent()
        cell?.textLabel?.textColor = UIColor.white
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 20)
        cell?.textLabel?.text = contact
        cell?.separatorInset = UIEdgeInsets.zero
        cell?.preservesSuperviewLayoutMargins = false
        cell?.layoutMargins = UIEdgeInsets.zero
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true);
        var url:URL?
        if (indexPath as NSIndexPath).row == 0 {
            url = URL(string:"prefs:root=NOTIFICATIONS_ID")
        }else {
            url = URL(string:"prefs:root=Phone&path=Blocked")
        }
        
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.openURL(url!)
        }
    }
    
    func showMessage(_ message: String) {
        let alertController = UIAlertController(title: "Test", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let dismissAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action) -> Void in
        }
        
        alertController.addAction(dismissAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func askForAddressBookAccess() {
        ABAddressBookRequestAccessWithCompletion(addressBookRef) { (granted, error) in
            DispatchQueue.main.async {
                if !granted {
                    self.displayCantAddContactAlert()
                }
            }
        }
    }
    
    func openSettings() {
        let url = URL(string: UIApplicationOpenSettingsURLString)
        UIApplication.shared.openURL(url!)
    }
    
    func displayCantAddContactAlert() {
        let cantAddContactAlert = UIAlertController(title: "Cannot Add Contact",
                                                    message: "You must give the app permission to add the contact first.",
                                                    preferredStyle: .alert)
        cantAddContactAlert.addAction(UIAlertAction(title: "Change Settings",
            style: .default,
            handler: { action in
                self.openSettings()
        }))
        cantAddContactAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(cantAddContactAlert, animated: true, completion: nil)
    }
    
    func peoplePickerNavigationController(_ peoplePicker: ABPeoplePickerNavigationController, didSelectPerson person: ABRecord) {
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
