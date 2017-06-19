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
import RxRealm
import RxRealmDataSources

class AlarmViewController: UITableViewController {
    
    var disposeBag = DisposeBag()
    
    let identifier = "AlarmTableViewCell"
    
    override func viewDidLoad() {
        self.tableView.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
        self.tableView.backgroundColor = UIColor("#E4C590")
        self.tableView.separatorColor = .white
        navigationController?.navigationItem.rightBarButtonItem = self.editButtonItem
        print("Karl: Init")
        let dataSource = RxTableViewRealmDataSource<MEDAlarm>(cellIdentifier: identifier, cellType: AlarmTableViewCell.self){cell, ip, alarm in
            print("Karl: Oei")
            cell.alarm = alarm
        }
        dataSource.rowAnimations.update = .none
        dataSource.rowAnimations.delete = .none
        dataSource.rowAnimations.insert = .none
        let realm = try! Realm()
        let alarms = Observable.changeset(from: realm.objects(MEDAlarm.self))
            .share()
        alarms.bind(to: tableView.rx.realmChanges(dataSource)).addDisposableTo(disposeBag)
    }
}
// Delegates
extension AlarmViewController{
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88.0
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?{
        return [UITableViewRowAction(style: .destructive, title: "Delete", handler: { (action, indexPath) in
            self.tableView(tableView, commit: .delete, forRowAt: indexPath)
        })]
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
