//
//  PhysioDeviceViewController.swift
//  Drone
//
//  Created by Karl-John on 29/8/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//


import UIKit
import SwiftEventBus

class PhysioDeviceViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableview: UITableView!

    let cellIdentifier:String = "cellIdentifier"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Add Device"
        let header:PhysioDeviceHeader = UIView.loadFromNibNamed("PhysioDeviceHeader") as! PhysioDeviceHeader;
        header.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, header.frame.height)
        let headerView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, header.frame.height))
        headerView.addSubview(header)
        tableview.tableHeaderView = headerView
        self.addCloseButton(#selector(close))
        initEventbus()
        self.getAppDelegate().startConnect()
    }
    
    func close(){
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

// extension for TableView
extension PhysioDeviceViewController{
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell
//        let cockroachUUID = self.cockroachUUIDS[indexPath.row]
        if let dequeuedCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier){
            cell = dequeuedCell
        }else{
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        }
//        cell.textLabel?.text = "Cockroach: \(cockroachUUID.UUIDString)"
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            tableview.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
}

// extension for eventbus
extension PhysioDeviceViewController{
    private func initEventbus(){
        SwiftEventBus.onMainThread(self, name: SWIFTEVENT_BUS_COCKROACHES_CHANGED) { (data) -> Void in
            let object = data.object! as! CockroachMasterChanged
                object.address
            self.tableview.reloadData()
        }
    }
    
    
}
