//
//  DeviceViewController.swift
//  Drone
//
//  Created by Karl-John on 1/5/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import UIKit

class DeviceViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    var leftRightButtonsNeeded = true;
    
    @IBOutlet weak var deviceTableView: UITableView!
    private final let identifier = "device_table_view_cell"
    private final let identifier_header = "device_table_view_cell_header"
    
    init() {
        super.init(nibName: "DeviceViewController", bundle: NSBundle.mainBundle())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deviceTableView.registerNib(UINib(nibName: "DeviceTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: identifier)
        deviceTableView.registerNib(UINib(nibName: "DeviceTableViewCellHeader", bundle: NSBundle.mainBundle()), forHeaderFooterViewReuseIdentifier: identifier_header)
        
    }
    
    override func viewDidLayoutSubviews() {
        deviceTableView.sectionHeaderHeight = 254
        deviceTableView.scrollEnabled = false
        deviceTableView.rowHeight = (deviceTableView.frame.height - 254)/2
        deviceTableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.row == 0 {
            self.navigationController?.pushViewController(ContactsNotificationViewController(), animated: true)
        }else if indexPath.row == 1 {
            // forget watch
            let alertView:UIAlertController = UIAlertController(title: NSLocalizedString("forget_watch", comment: ""), message: NSLocalizedString("forget_watch_message", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
            
            alertView.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: UIAlertActionStyle.Default, handler: { (action) in
                AppDelegate.getAppDelegate().sendRequest(ClearConnectionRequest())
                
                if self.navigationController == nil {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }else{
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }))
            
            alertView.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: UIAlertActionStyle.Cancel, handler: { (action) in
                
            }))
            
            self.presentViewController(alertView, animated: true, completion: nil)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell: DeviceTableViewCellHeader = deviceTableView.dequeueReusableHeaderFooterViewWithIdentifier(identifier_header) as! DeviceTableViewCellHeader
            headerCell.showLeftRightButtons(leftRightButtonsNeeded);
        return headerCell;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: DeviceTableViewCell = tableView.dequeueReusableCellWithIdentifier(identifier) as! DeviceTableViewCell
        if indexPath.row == 0 {
            cell.titleLabel.text = "Contacts Notifications"
        }else if indexPath.row == 1{
            cell.titleLabel.text = "Forget this watch"
        }
        cell.separatorInset = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsZero
        return cell
    }
}