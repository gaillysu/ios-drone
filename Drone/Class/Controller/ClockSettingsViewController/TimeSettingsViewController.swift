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
import RxDataSources

class TimeSettingsViewController: BaseViewController {
    
    let items:Variable<[String]> = Variable(["Sync local time automatically"])
    let identifierSwitch = "ClockSettingsTableViewCellSwitch"
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let section = Variable([SectionModel(model: "Local Time Syncing", items: [TimeSettingsSectionItem(label: "Sync local time automatically", status: false)])])
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String,TimeSettingsSectionItem>>()
        self.tableView.register(UINib(nibName: identifierSwitch, bundle: Bundle.main), forCellReuseIdentifier: identifierSwitch)
        
        dataSource.configureCell = { (dataSource, table, indexPath, _) in
            if let cell = table.dequeueReusableCell(withIdentifier: self.identifierSwitch, for: indexPath) as? ClockSettingsTableViewCellSwitch{
                let item = dataSource[indexPath]
                cell.settingLabel.text = item.label
                cell.settingSwitch.setOn(DTUserDefaults.syncLocalTime, animated: true)
                cell.settingSwitch.rx.controlEvent(UIControlEvents.valueChanged).subscribe({ event in
                    DTUserDefaults.syncLocalTime = cell.settingSwitch.isOn
                    self.getAppDelegate().subscribeToSignificantTimeChange(on: DTUserDefaults.syncLocalTime)
                    
                }).addDisposableTo(self.disposeBag)
                return cell
            }
            return UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: nil)
        }
        
        section.asObservable()
            .bindTo(tableView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)
        
        dataSource.titleForHeaderInSection = { dataSource, index in
            let section = dataSource[index]
            return section.model
        }
        
        dataSource.titleForFooterInSection = { dataSource, index in

            
        }
        //        tableView.register(UINib(nibName: identifierSwitch, bundle: Bundle.main), forCellReuseIdentifier: identifierSwitch)
        //        items.asObservable().bindTo(tableView.rx
        //            .items(cellIdentifier: identifierSwitch, cellType: ClockSettingsTableViewCellSwitch.self)){
        //                row, item, cell in
        //                cell.settingLabel.text = item
        //                if row == 0 {
        //                    cell.settingSwitch.setOn(DTUserDefaults.syncLocalTime, animated: true)
        //                    cell.settingSwitch.rx.controlEvent(UIControlEvents.valueChanged).subscribe({ event in
        //                        DTUserDefaults.syncLocalTime = cell.settingSwitch.isOn
        //                        self.getAppDelegate().subscribeToSignificantTimeChange(on: DTUserDefaults.syncLocalTime)
        //
        //                    }).addDisposableTo(self.disposeBag)
        //                }
        //            }.addDisposableTo(disposeBag)
        //
        //        tableView.rx.modelSelected(String.self).subscribe { _ in
        //            if let indexPath = self.tableView.indexPathForSelectedRow {
        //                if let cell = self.tableView.cellForRow(at: indexPath) as? ClockSettingsTableViewCellSwitch{
        //                    DTUserDefaults.syncLocalTime = !cell.settingSwitch.isOn
        //                    cell.settingSwitch.setOn(DTUserDefaults.syncLocalTime, animated: true)
        //                    self.getAppDelegate().subscribeToSignificantTimeChange(on: DTUserDefaults.syncLocalTime)
        //                }
        //                self.tableView.deselectRow(at: indexPath, animated: true)
        //            }
        //            }.addDisposableTo(disposeBag)
        
        
    }
}



