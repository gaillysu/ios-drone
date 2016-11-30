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
    fileprivate var contactsFilterArray:[String] = []
    fileprivate var contactsFilterDict:[String:Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Notifications"
        self.navigationController!.navigationBar.topItem!.title = "";

        self.tableView.separatorColor = UIColor.clear
        self.tableView.rowHeight = 60.0
        
        let header:UIView = UIView.loadFromNibNamed("ContactsNotificationHeader")!
        header.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: header.frame.height)
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: header.frame.height))
        headerView.addSubview(header)
        //self.tableView.tableHeaderView = headerView
        self.tableView.register(UINib(nibName: "NotificationsViewCell", bundle: nil), forCellReuseIdentifier: "Notifications_Identifier")
        peoplePicker.peoplePickerDelegate = self;
        
        let contact:[String : Any] = SandboxManager().readDataWithName(type: "", fileName: "NotificationTypeFile.plist") as! [String : Any]
        let notificationType:[String:Any] = contact["NotificationType"] as! [String:Any]
        contactsFilterDict = notificationType
        for key in notificationType.keys {
            contactsFilterArray.append(key)
        }
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
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url!)
        }
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
}

extension ContactsNotificationViewController{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactsFilterArray.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:NotificationsViewCell = tableView.dequeueReusableCell(withIdentifier: "Notifications_Identifier", for: indexPath) as! NotificationsViewCell
        //cell.accessoryView = MSCellAccessory(type: DISCLOSURE_INDICATOR, color: UIColor.getTintColor())
        cell.backgroundColor = UIColor.transparent()
        let selectedView:UIView = UIView()
        selectedView.backgroundColor = UIColor.getBaseColor()
        cell.selectedBackgroundView = selectedView
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
        cell.separatorInset = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsets.zero
        let keys:String = contactsFilterArray[indexPath.row]
        cell.textLabel?.text = keys
        cell.contactsFilterDict = contactsFilterDict[keys] as! [String : Any]?
        cell.keys = keys
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true);
        var url:URL? = URL(string:"prefs:root=Phone&path=Blocked")
        if (indexPath as NSIndexPath).row == 0 {
            url = URL(string:"prefs:root=NOTIFICATIONS_ID")
        }
        
        if UIApplication.shared.canOpenURL(url!) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url!)
            }
        }
    }
}
