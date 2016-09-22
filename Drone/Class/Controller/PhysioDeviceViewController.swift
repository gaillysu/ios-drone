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
    var cockroaches:[MasterCockroach]  = []
    
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
        self.getAppDelegate().connectCockroach()
    }
    
    func close(){
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

// extension for TableView
extension PhysioDeviceViewController{
    @objc(tableView:cellForRowAtIndexPath:) func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let masterCockroach = self.cockroaches[indexPath.section]
        let baby = masterCockroach.getBabyCockroach(at: indexPath.row)
        return PhysioCellGenerator.getCellFrom(cockroach: baby.number, coordinates: baby.coordinateSet!, tableview: tableview, dequeueIdentifier: cellIdentifier)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.cockroaches[section].address.uuidString
    }
    
    @objc(tableView:didSelectRowAtIndexPath:) func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableview.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cockroaches[section].getAmountBabies()
    }
    
    @objc(numberOfSectionsInTableView:) func numberOfSections(in tableView: UITableView) -> Int {
        return cockroaches.count
    }
}

// extension for eventbus
extension PhysioDeviceViewController{
    fileprivate func initEventbus(){
        _ = SwiftEventBus.onMainThread(self, name: SWIFTEVENT_BUS_COCKROACHES_DATA_UPDATED) { (data) -> Void in
            let object = data.object! as! CockroachMasterDataReceived
            for cockroach in self.cockroaches {
                if cockroach.address == object.address{
                    cockroach.addOrUpdateBabyCockroach(byCockroachMasterDataReceived: object)
                    self.tableview.reloadData()
                    return
                }
            }
            self.cockroaches.append(MasterCockroach(WithMasterCockroachData: object))
            self.tableview.reloadData()
        }
    }
}
