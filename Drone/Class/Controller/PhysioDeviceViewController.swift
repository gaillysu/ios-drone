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
        header.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: header.frame.height)
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: header.frame.height))
        headerView.addSubview(header)
        tableview.tableHeaderView = headerView
        self.addCloseButton(#selector(close))
        initEventbus()
        self.getAppDelegate().startConnect()
    }
    
    func close(){
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

// extension for TableView
extension PhysioDeviceViewController{
    @objc(tableView:cellForRowAtIndexPath:) func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell
//        let cockroachUUID = self.cockroachUUIDS[indexPath.row]
        if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier){
            cell = dequeuedCell
        }else{
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: cellIdentifier)
        }
//        cell.textLabel?.text = "Cockroach: \(cockroachUUID.UUIDString)"
        return cell
    }
    
    @objc(tableView:didSelectRowAtIndexPath:) func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableview.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
}

// extension for eventbus
extension PhysioDeviceViewController{
    fileprivate func initEventbus(){
        _ = SwiftEventBus.onMainThread(self, name: SWIFTEVENT_BUS_COCKROACHES_CHANGED) { (data) -> Void in
            let object = data.object! as! CockroachMasterChanged
                // object.address
            
            // left here obviously
            self.tableview.reloadData()
        }
    }
    
    
}
