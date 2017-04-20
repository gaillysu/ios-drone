//
//  ClockSettingsViewController.swift
//  Drone
//
//  Created by Karl-John Chow on 20/4/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TimeSettingsViewController: BaseViewController {
    
    let items:Variable<[String]> = Variable(["Sync local time automatically"])
    let identifierSwitch = "ClockSettingsTableViewCellSwitch"
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: identifierSwitch, bundle: Bundle.main), forCellReuseIdentifier: identifierSwitch)
        items.asObservable().bindTo(tableView.rx
            .items(cellIdentifier: identifierSwitch, cellType: ClockSettingsTableViewCellSwitch.self)){
                row, item, cell in
                cell.settingLabel.text = item
                if row == 0{
                    cell.settingSwitch.setOn(DTUserDefaults.syncLocalTime, animated: true)
                    cell.settingSwitch.rx.controlEvent(UIControlEvents.valueChanged).subscribe({ event in
                        DTUserDefaults.syncLocalTime = cell.settingSwitch.isOn
                        self.getAppDelegate().subscribeToSignificantTimeChange(on: DTUserDefaults.syncLocalTime)

                    }).addDisposableTo(self.disposeBag)
                }
            }.addDisposableTo(disposeBag)
        
        tableView.rx.modelSelected(String.self).subscribe { _ in
            if let indexPath = self.tableView.indexPathForSelectedRow {
                if let cell = self.tableView.cellForRow(at: indexPath) as? ClockSettingsTableViewCellSwitch{
                    DTUserDefaults.syncLocalTime = !cell.settingSwitch.isOn
                    cell.settingSwitch.setOn(DTUserDefaults.syncLocalTime, animated: true)
                    self.getAppDelegate().subscribeToSignificantTimeChange(on: DTUserDefaults.syncLocalTime)
                }
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
            }.addDisposableTo(disposeBag)
    }
}
