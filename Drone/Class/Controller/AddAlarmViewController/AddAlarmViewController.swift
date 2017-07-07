//
//  AddAlarmViewController.swift
//  Drone
//
//  Created by Karl-John Chow on 19/6/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift
import RxCocoa
import MSCellAccessory

class AddAlarmViewController: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!
    
    let disposeBag = DisposeBag()
    
    let viewModel:AddAlarmViewModel
    
    let normalIdentifier = "AddAlarmTableViewCell"
    let deleteIdentifier = "AddAlarmDeleteTableViewCell"
    
    let snoozeSwitch = UISwitch()
    
    
    init(viewModel:AddAlarmViewModel) {
        self.viewModel = viewModel
        self.snoozeSwitch.setOn(viewModel.snoozable, animated: true)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if viewModel.inEditMode {
            title = "Edit Alarm"
        } else {
            title = "Add Alarm"
        }
        let now = Date()
        self.datePicker.setDate(now.changed(hour: viewModel.time.hour, minute: viewModel.time.minute)!, animated: true)
        snoozeSwitch.onTintColor = .getTintColor()
        
        datePicker.rx.date.subscribe { event in
            if let date = event.element{
                self.viewModel.time = (hour: date.hour, minute: date.minute)
            }
            }.addDisposableTo(disposeBag)
        
        tableView.register(UINib(nibName: normalIdentifier, bundle: nil), forCellReuseIdentifier: normalIdentifier)
        tableView.register(UINib(nibName: deleteIdentifier, bundle: nil), forCellReuseIdentifier: deleteIdentifier)
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, (title:String,detail:String)>>()
        datePicker.setValue(UIColor.white, forKey: "textColor")
        dataSource.configureCell = { (dataSource, tableView, indexPath, item) in
            if indexPath.section == 0 {
                let cell:AddAlarmTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.textLabel?.text = item.title
                cell.detailTextLabel?.text = item.detail
                if [0,1].contains(indexPath.row) && indexPath.section == 0 {
                    cell.accessoryView = MSCellAccessory(type: FLAT_DISCLOSURE_INDICATOR, color: .white)
                } else if indexPath.row == 2 {
                    cell.accessoryView = self.snoozeSwitch
                    cell.selectionStyle = .none
                } else if indexPath.row == 0 && indexPath.section == 1{
                    cell.textLabel?.textAlignment = .center
                }
                return cell
            }
            let cell:AddAlarmDeleteTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            return cell
        }
        
        viewModel.data
            .asObservable()
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)
        
        tableView.rx.itemSelected.subscribe { event in
            if let indexPath = event.element{
                self.tableView.deselectRow(at: indexPath, animated: true)
                switch (indexPath.section, indexPath.row){
                case (0,0):
                    self.navigationController?.pushViewController(RepeatAlarmViewController(viewModel: self.viewModel.repeatViewModel()), animated: true)
                case (0,1):
                    let labelAlertController = UIAlertController(title: "Label", message: nil, preferredStyle: .alert)
                    labelAlertController.addTextField(configurationHandler: { textField in
                        textField.text = self.viewModel.alarmLabel
                        textField.clearButtonMode = .whileEditing
                    })
                    labelAlertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { item in
                        if let textfields = labelAlertController.textFields, let newAlarmLabel = textfields[0].text {
                            self.viewModel.alarmLabel = newAlarmLabel
                        }
                    }))
                    labelAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(labelAlertController, animated: true, completion: nil)
                    
                case (1,0):
                    let deleteAlarmAlertController = UIAlertController(title: "Delete", message: "Do you really want to delete this alarm?", preferredStyle: .alert)
                    deleteAlarmAlertController.addAction(UIAlertAction(title: "Delete", style: .default, handler: { item in
                        self.viewModel.deleteAlarm()
                        self.navigationController?.popViewController(animated: true)
                    }))
                    deleteAlarmAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(deleteAlarmAlertController, animated: true, completion: nil)
                    
                default: break
                }
            }
            }.addDisposableTo(disposeBag)
        
        snoozeSwitch.rx.isOn
            .debounce(0.1, scheduler: MainScheduler.instance)
            .subscribe {
                if let enabled = $0.element{
                    self.viewModel.snoozable = enabled
                }
            }.addDisposableTo(disposeBag)
        
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    func back(sender: UIBarButtonItem) {
        viewModel.syncAlarms()
        _ = navigationController?.popViewController(animated: true)
    }
    
}
