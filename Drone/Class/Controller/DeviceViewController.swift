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
    private let devicesViewController: MyDeviceViewController;
    
    init(controller devicesViewController: MyDeviceViewController) {
        self.devicesViewController = devicesViewController
        super.init(nibName: "DeviceViewController", bundle: NSBundle.mainBundle())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        deviceTableView.registerNib(UINib(nibName: "DeviceTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: identifier)
        deviceTableView.registerNib(UINib(nibName: "DeviceTableViewCellHeader", bundle: NSBundle.mainBundle()), forHeaderFooterViewReuseIdentifier: identifier_header)
        deviceTableView.scrollEnabled = false
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.row == 0 {
            self.devicesViewController.pushContactsFilterViewController()
        }else if indexPath.row == 1 {
            // forget watch
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
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 254;
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return ((tableView.frame.height - 388)/2);
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: DeviceTableViewCell = tableView.dequeueReusableCellWithIdentifier(identifier) as! DeviceTableViewCell
        cell.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, cell.frame.height)
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