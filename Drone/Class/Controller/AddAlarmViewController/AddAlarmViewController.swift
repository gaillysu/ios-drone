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
        title = "Alarm"
        let now = Date()
        self.datePicker.setDate(now.change(year: nil, month: nil, day: nil, hour: viewModel.time.hour, minute: viewModel.time.minute, second: nil), animated: true)
        snoozeSwitch.rx.isOn.subscribe {
            if let enabled = $0.element{
                self.viewModel.snoozable = enabled
            }
            }.addDisposableTo(disposeBag)
        datePicker.rx.date.subscribe { event in
            if let date = event.element{
                self.viewModel.time = (hour: date.hour, minute: date.minute)
                print("\(date.hour), \(date.minute)")
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
                    break
                case (0,1):
                    let labelAlertController = UIAlertController(title: "Label", message: nil, preferredStyle: .alert)
                    labelAlertController.addTextField(configurationHandler: { textField in
                        
                    })
                    labelAlertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { item in
                        
                    }))
                    labelAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    
                    break
                case (1,0):
                    break
                default: break
                }
            }
            }.addDisposableTo(disposeBag)
    }
}
