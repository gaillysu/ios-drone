//
//  AlarmViewController.swift
//  Drone
//
//  Created by Karl-John Chow on 16/6/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import RxSwift
import RxCocoa
import RxDataSources

class AlarmViewController: UITableViewController {
    
    var disposeBag = DisposeBag()
    
    let identifier = "AlarmTableViewCell"
    
    let alarmViewModel = AlarmViewModel()
    
    override func viewDidLoad() {
        
        self.tableView.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
        self.tableView.backgroundColor = UIColor("#E4C590")
        self.tableView.separatorColor = .white
        self.tableView.rowHeight = 88.0
        self.tableView.sectionHeaderHeight = 0.0
        
        navigationController?.navigationItem.rightBarButtonItem = self.editButtonItem
        let dataSource = RxTableViewSectionedAnimatedDataSource<AlarmSectionViewModel>()
        dataSource.animationConfiguration = AnimationConfiguration(insertAnimation: .fade, reloadAnimation: .fade, deleteAnimation: .fade)
        dataSource.configureCell = { (dataSource, tableView, indexPath, item) in
            let cell:AlarmTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.alarm = item.alarm
            return cell
        }
        tableView.dataSource = nil
        tableView.delegate = nil
        
        dataSource.canEditRowAtIndexPath = { _ in false }
        
        alarmViewModel.data.asObservable()
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)

        tableView.rx.itemSelected.subscribe{ event in
            if let indexPath = event.element{
                if let alarm = self.alarmViewModel.getAlarmFor(index: indexPath.row) {
                    let viewModel = AddAlarmViewModel(alarm: alarm, inEditMode: true)
                    self.navigationController?.pushViewController(AddAlarmViewController(viewModel: viewModel), animated: true)
                }
            }
        }.addDisposableTo(disposeBag)
        
        tableView.rx.setDelegate(self).addDisposableTo(disposeBag)
        
        if let tabBarController = tabBarController {
            self.tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: tabBarController.tabBar.frame.height, right: 0.0)
        }
        
    }
}
// Delegates This section does not work actually but I want to make it work :@
extension AlarmViewController{
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?{
        return [UITableViewRowAction(style: .destructive, title: "Delete", handler: { (action, indexPath) in
            self.tableView(tableView, commit: .delete, forRowAt: indexPath)
        })]
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        self.alarmViewModel.delete(index: indexPath.row)
    }
 
}
