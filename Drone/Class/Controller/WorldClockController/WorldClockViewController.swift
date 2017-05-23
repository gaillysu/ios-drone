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
    fileprivate var worldClockArray: [City] = []
    fileprivate var homeCityArray: [City] = []
    fileprivate var localCityArray: [City] = []
    fileprivate let realm:Realm
    
    var enableEditingFirstRow = false
    var previousSelectedIndexPath: IndexPath?
    
    
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
        let results:Results<City> = realm.objects(City.self).filter("name CONTAINS[c] '\(DateFormatter().localCityName())'")
        results.forEach({ localCityArray.append($0) })
        updateWorldClockArrayWithOrder(reload: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateWorldClockArrayWithOrder(reload: true)
    }
    
    fileprivate func updateWorldClockArrayWithOrder(reload:Bool){
        worldClockArray = []
        homeCityArray = []
        var selectedCityOrder = DTUserDefaults.selectedCityOrder
        if selectedCityOrder.isEmpty {
            realm.objects(City.self)
                .filter("selected = true")
                .sorted(by: {
                    ($0.timezone?.getOffsetFromUTC())! < ($1.timezone?.getOffsetFromUTC())!})
                .forEach({
                    if $0.id == DTUserDefaults.homeTimeId{
                        homeCityArray.append($0)
                    } else {
                        worldClockArray.append($0)
                    }})
        } else {
            let selectedCtities = Array(realm.objects(City.self).filter("selected = true"))
            if selectedCtities.count != selectedCityOrder.count{
                if selectedCtities.count > selectedCityOrder.count {
                    selectedCtities.forEach({ city in
                        if !selectedCityOrder.contains(where: { $0 == city.id }){
                            selectedCityOrder.append(city.id)
                            DTUserDefaults.selectedCityOrder = selectedCityOrder
                        }
                    })
                }else{
                    selectedCtities.forEach({ city in
                        if !selectedCityOrder.contains(where: { $0 == city.id }){
                            if let index = selectedCityOrder.index(where: { $0 == city.id }){
                                selectedCityOrder.remove(at: index)
                            }
                        }
                    })
                }
            }
            selectedCityOrder.forEach({ cityId in
                if let city = realm.object(ofType: City.self, forPrimaryKey: cityId){
                    if city.selected{
                        if city.id == DTUserDefaults.homeTimeId {
                            homeCityArray.append(city)
                        }else{
                            worldClockArray.append(city)
                        }
                    }
                }
            })
        }
        
        if reload {
            self.tableView.reloadData()
        }
        AppDelegate.getAppDelegate().setWorldClock(Array(homeCityArray + worldClockArray))
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
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        previousSelectedIndexPath = indexPath
        if homeCityArray.count  >= 1 && previousSelectedIndexPath?.section == 1 {
            enableEditingFirstRow = true
        }else if homeCityArray.count == 0 {
            enableEditingFirstRow = true
        } else{
            enableEditingFirstRow = false
        }
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
            })
            updateWorldClockArrayWithOrder(reload: false)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let spacer = tableView.reorder.spacerCell(for: indexPath) {
            return spacer
        }
        let cell:WorldClockCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! WorldClockCell
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
        if indexPath.section == 0 {
            return false
        } else if indexPath.section == 1 && !enableEditingFirstRow{
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, reorderRowAt s: IndexPath, to d: IndexPath) {
        if s.section > d.section {
            let city = worldClockArray[s.row]
            homeCityArray.insert(city, at: d.row)
            worldClockArray.remove(at: s.row)
            DTUserDefaults.homeTimeId = city.id
            if !DTUserDefaults.syncLocalTime {
                getAppDelegate().setAnalogTime(forceCurrentTime: false)
                print("Not forcing current time")
            }
            
        } else if d.section > s.section {
            let city = homeCityArray[s.row]
            worldClockArray.insert(city, at: d.row)
            homeCityArray.remove(at: s.row)
            DTUserDefaults.homeTimeId = -1
            print("Forcing current time")
            getAppDelegate().setAnalogTime(forceCurrentTime: true)
        } else {
            let destination = s.row
            let source = d.row
            if(s.section == 1) {
                (homeCityArray[source], homeCityArray[destination]) = (homeCityArray[destination], homeCityArray[source])
            } else if(s.section == 2) {
                (worldClockArray[source], worldClockArray[destination]) = (worldClockArray[destination], worldClockArray[source])
            }
            DTUserDefaults.selectedCityOrder = homeCityArray.map({ $0.id }) + worldClockArray.map({ $0.id })
        }
    }
    
    func tableViewDidFinishReordering(_ tableView: UITableView) {
        Array(homeCityArray + worldClockArray).forEach { print("\($0.name)") }
        updateWorldClockArrayWithOrder(reload: true)
    }
}




