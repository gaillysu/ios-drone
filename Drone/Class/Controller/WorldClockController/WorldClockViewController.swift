//
//  WorldClockController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/25.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit
import MRProgress
import RealmSwift
import SwiftReorder
import RxSwift
import RxCocoa

class WorldClockViewController: BaseViewController{
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate let identifier:String = "WorldClockCell"
    
    fileprivate var localCityArray: [City] = []
    fileprivate var homeCityArray: [City] = []
    fileprivate var worldClockArray: [City] = []
    fileprivate let realm:Realm
    
    init() {
        realm = try! Realm()
        super.init(nibName: "WorldClockViewController", bundle: Bundle.main)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: identifier,bundle: Bundle.main), forCellReuseIdentifier: identifier)
        tableView.reorder.delegate = self
        self.dateLabel.text = "\(DateFormatter().normalDateString())"
        if let city = City
            .byFilter("name LIKE[c] '\(DateFormatter().localCityName())'")
            .first {
            localCityArray.append(city)
        }else if let city = City
            .byFilter("name CONTAINS[c] '\(DateFormatter().localCityName())'")
            .first {
            localCityArray.append(city)
        }
        
        updateWorldClockArrayWithOrder(reload: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateWorldClockArrayWithOrder(reload: true)
    }
    
    fileprivate func updateWorldClockArrayWithOrder(reload:Bool){
        worldClockArray = City.worldClockCities
        homeCityArray.removeAll()
        if let homeTime = City.homeTime{
            homeCityArray.append(homeTime)
        }
        if reload {
            self.tableView.reloadData()
        }
        getAppDelegate().setWorldClock()
    }
}

extension WorldClockViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?{
        let deleteButton = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
            self.tableView(tableView, commit: .delete, forRowAt: indexPath)
        })
        deleteButton.backgroundColor = UIColor.getTintColor()
        return [deleteButton]
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "Local Time"
        } else if section == 1{
            return "Home Time"
        }else if section == 2{
            return "World Time"
        }
        return "Unknown Section"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            let navigationController: UINavigationController = UINavigationController(rootViewController: AddWorldClockViewController(forHomeTime: true))
            navigationController.navigationBar.setBackgroundImage(UIImage(named: "gradually"), for: UIBarMetrics.default)
            let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
            navigationController.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
            self.present(navigationController, animated: true, completion: nil)
        }
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return localCityArray.count
        } else if section == 1 {
            return homeCityArray.count
        }else if section == 2 {
            return worldClockArray.count
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0  || indexPath.section == 1 ? false : true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let city:City = worldClockArray[indexPath.row]
            try! realm.write({
                city.selected = false
                var cityOrder = DTUserDefaults.selectedCityOrder
                if !cityOrder.isEmpty{
                    if let index = cityOrder.index(where: {$0 == city.id}){
                        cityOrder.remove(at: index)
                        DTUserDefaults.selectedCityOrder = cityOrder
                    }
                }
            })
            updateWorldClockArrayWithOrder(reload: false)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let spacer = tableView.reorder.spacerCell(for: indexPath) {
            return spacer
        }
        let cell:WorldClockCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        var city:City?
        if indexPath.section == 0 {
            city = localCityArray.first
        }else if indexPath.section == 1 {
            city = homeCityArray[indexPath.row]
        }else if indexPath.section == 2 {
            city = worldClockArray[indexPath.row]
        }
        cell.cityModel = city
        return cell;
    }
}

extension WorldClockViewController:TableViewReorderDelegate{
    
    func tableView(_ tableView: UITableView, canReorderRowAt indexPath: IndexPath) -> Bool {
        return (indexPath.section == 0 || indexPath.section == 1)  ? false : true
    }
    
    func tableView(_ tableView: UITableView, reorderRowAt s: IndexPath, to d: IndexPath) {
        let destination = s.row
        let source = d.row
        (worldClockArray[source], worldClockArray[destination]) = (worldClockArray[destination], worldClockArray[source])
        DTUserDefaults.selectedCityOrder = worldClockArray.map({ $0.id })
        getAppDelegate().setWorldClock()
    }
    
    func tableViewDidFinishReordering(_ tableView: UITableView) {
        updateWorldClockArrayWithOrder(reload: true)
    }
}
