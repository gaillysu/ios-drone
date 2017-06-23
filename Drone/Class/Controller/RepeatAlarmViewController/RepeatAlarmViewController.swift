//
//  RepeatAlarmViewController.swift
//  Drone
//
//  Created by Karl-John Chow on 22/6/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import UIKit
import RxSwift
import MSCellAccessory

class RepeatAlarmViewController: UITableViewController {

    let viewModel:RepeatAlarmViewModel
    let identifier = "UITableViewCell"
    let disposeBag = DisposeBag()
    
    init(viewModel:RepeatAlarmViewModel) {
        self.viewModel = viewModel
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let daysInWeek = Observable.just([
        "Sunday",
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday"])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Repeat"
        tableView.backgroundColor = UIColor.getLightBaseColor()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        tableView.delegate = nil
        tableView.dataSource = nil
        
        daysInWeek.bind(to: tableView.rx.items(cellIdentifier: identifier)) { index, model, cell in
            cell.textLabel?.text = model
            cell.backgroundColor = .getBaseColor()
            cell.tintColor = .white
            cell.textLabel?.textColor = .white
            if self.viewModel.selectedWeekDays.contains(index){
                cell.accessoryType = .checkmark
            }}.disposed(by: disposeBag)


        tableView.rx.itemSelected.subscribe({ event in
            if let indexPath = event.element, let cell = self.tableView.cellForRow(at: indexPath){
                if self.viewModel.selectedWeekDays.contains(indexPath.row){
                    cell.accessoryType = .none
                    self.viewModel.removeWeekDay(day: indexPath.row)
                }else{
                    cell.accessoryType = .checkmark
                    self.viewModel.addWeekDay(day: indexPath.row)
                }
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
        }).addDisposableTo(disposeBag)
    }
}
