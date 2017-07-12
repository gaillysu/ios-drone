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
import BRYXBanner

class TimeSettingsViewController: BaseViewController {
    
    var disposeBag = DisposeBag()
    let identifier = "ClockSettingsTableViewCell"
    let identifierSwitch = "ClockSettingsTableViewCellSwitch"
    let syncTimeItems = ["Local Time","Home Time"]
    let hourFormat = ["12 Hour Format","24 Hour Format"]
    
    
    @IBOutlet weak var tableView: UITableView!
    let pickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        self.tableView.register(UINib(nibName: identifierSwitch, bundle: Bundle.main), forCellReuseIdentifier: identifierSwitch)
        self.tableView.register(UINib(nibName: identifier, bundle: Bundle.main), forCellReuseIdentifier: identifier)
        let section = Variable(
            [TimeSettingsSectionModel(header: "Analog Time Display", footer: "Sync the time of your watch with local or home time If you don't turn on Analog Time Syncing, the time on your watch will never change.", items: [
                TimeSettingsSectionItem(label: "Analog Time Syncing", enabled: DTUserDefaults.syncAnalogTime),
                TimeSettingsSectionItem(label: "Sync Time"),
                TimeSettingsSectionItem(label: "24 Hour Format", enabled: DTUserDefaults.hourFormat == 1 ? true : false),
                TimeSettingsSectionItem(label: "Stopwatch", enabled: DTUserDefaults.stopwatchEnabled),
                TimeSettingsSectionItem(label: "Timer", enabled: DTUserDefaults.timerEnabled)]),
             TimeSettingsSectionModel(header: "Calibration", footer: "", items: [
                TimeSettingsSectionItem(label: "Recalibrate hands")])])
        
        let dataSource = RxTableViewSectionedReloadDataSource<TimeSettingsSectionModel>()
        
        dataSource.configureCell = { (dataSource, table, indexPath, _) in
            let item = dataSource[indexPath]
            if let _ = item.enabled{
                let cell:ClockSettingsTableViewCellSwitch  = table.dequeueReusableCell(forIndexPath: indexPath)
                cell.item = item
                switch (indexPath.row, indexPath.section){
                case (0,0):
                    cell.settingSwitch.rx.controlEvent(UIControlEvents.valueChanged).subscribe({ _ in
                        let isOn = cell.settingSwitch.isOn
                        DTUserDefaults.syncAnalogTime = isOn
                        if let localTimeCell = self.tableView.cellForRow(at: IndexPath(item: 1, section: 0)){
                            localTimeCell.enable(on: isOn)
                        }
                        if isOn {
                            self.getAppDelegate().setRTC(force: false)
                            self.getAppDelegate().setAnalogTime(forceCurrentTime: false)
                        }
                    }).addDisposableTo(self.disposeBag)
                case (2,0):
                    cell.settingSwitch.rx.controlEvent(UIControlEvents.valueChanged).subscribe({ _ in
                        DTUserDefaults.hourFormat = cell.settingSwitch.isOn ? 1 : 0
                        self.getAppDelegate().setTimeFormat()
                    }).addDisposableTo(self.disposeBag)
                case (3,0):
                    cell.settingSwitch.rx.controlEvent(UIControlEvents.valueChanged).subscribe({ _ in
                        DTUserDefaults.hourFormat = cell.settingSwitch.isOn ? 1 : 0
                        self.getAppDelegate().setTimeFormat()
                    }).addDisposableTo(self.disposeBag)
                case (4,0):
                    cell.settingSwitch.rx.controlEvent(UIControlEvents.valueChanged).subscribe({ _ in
                        DTUserDefaults.stopwatchEnabled = cell.settingSwitch.isOn
                        self.getAppDelegate().setStopwatch()
                    }).addDisposableTo(self.disposeBag)
                case (5,0):
                    cell.settingSwitch.rx.controlEvent(UIControlEvents.valueChanged).subscribe({ _ in
                        DTUserDefaults.timerEnabled = cell.settingSwitch.isOn
                        self.getAppDelegate().setTimer()
                    }).addDisposableTo(self.disposeBag)
                default: break
                }
                return cell
            }else{
                let cell:ClockSettingsTableViewCell = table.dequeueReusableCell(forIndexPath: indexPath)
                cell.item = item
                switch (indexPath.row, indexPath.section) {
                case (1,0):
                    cell.settingsTextField.inputView = self.pickerView
                    cell.settingsTextField.text = DTUserDefaults.syncLocalTime ? self.syncTimeItems[0] : self.syncTimeItems[1]
                    cell.enable(on: DTUserDefaults.syncAnalogTime)
                    cell.selectionStyle = .none
                default:
                    cell.settingsTextField.isEnabled = false
                    cell.accessoryType = .disclosureIndicator
                }
                return cell
            }
        }
        
        
        dataSource.titleForHeaderInSection = { dataSource, index in
            let section = dataSource[index]
            return section.header
        }
        
        dataSource.titleForFooterInSection = { dataSource, index in
            let section = dataSource[index]
            return section.footer
        }
        
        section.asObservable()
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)
        
        self.tableView.rx.modelSelected(TimeSettingsSectionItem.self).subscribe { _ in
            if let indexPath = self.tableView.indexPathForSelectedRow{
                self.tableView.deselectRow(at: indexPath, animated: true)
                if indexPath.section == 1 && indexPath.row == 0 {
                    if !(self.getAppDelegate().getMconnectionController()?.isConnected())!{
                        let banner = Banner(title: "Watch is disconnected, connect to calibrate.", subtitle: nil, image: nil, backgroundColor:UIColor.getBaseColor())
                        banner.dismissesOnTap = true
                        banner.show(duration: 1.2)
                    }else{
                        self.present(self.makeStandardUINavigationController(CalibrateHourViewController()), animated: true)
                    }
                }
            }
            }.addDisposableTo(self.disposeBag)
    }
}

extension TimeSettingsViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? ClockSettingsTableViewCell{
            DTUserDefaults.syncLocalTime = row == 0 ? true:false
            cell.settingsTextField.text = self.syncTimeItems[row]
            getAppDelegate().setAnalogTime(forceCurrentTime: false)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.syncTimeItems[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.syncTimeItems.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}


