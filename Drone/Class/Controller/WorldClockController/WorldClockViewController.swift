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

protocol DidSelectedDelegate:NSObjectProtocol {
    func didSelectedLocalTimeZone(_ cityId:Int)
}

class WorldClockViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate let identifier:String = "WorldClockCell"
    fileprivate var worldClockArray: [City] = []
    fileprivate var homeCity: [City] = []
    fileprivate var localCity: [City] = []
    fileprivate let realm:Realm
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter
    }()
    
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
        
        self.dateLabel.text = "\(dateFormatter.string(from: Date()))"
        
        let timeZoneNameData = DateFormatter.localCityName()
        let results:Results<City> = realm.objects(City.self).filter("name CONTAINS[c] '\(timeZoneNameData)'")
        for city in results {
            localCity.append(city)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateWorldClockArrayWithOrder(reload: true)
    }
    
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
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return localCity.count
        } else if section == 1 {
            return homeCity.count
        }else if section == 2 {
            return worldClockArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (indexPath as NSIndexPath).section == 0 {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let city:City = worldClockArray[indexPath.row]
            try! realm.write({
                city.selected = false
                realm.add(city, update: true)
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
            city = localCity.first
        }else if indexPath.section == 1 {
            city = homeCity[indexPath.row]
        }else if indexPath.section == 2 {
            city = worldClockArray[indexPath.row]
        }
        cell.cityModel = city

        return cell;
    }
    
    fileprivate func updateWorldClockArrayWithOrder(reload:Bool){
        worldClockArray = []
        homeCity = []
        var selectedCityOrder = DTUserDefaults.selectedCityOrder
        if selectedCityOrder.isEmpty {
            print("We have selected order is empty")
            realm.objects(City.self).filter("selected = true").sorted(by: {
                ($0.timezone?.getOffsetFromUTC())! < ($1.timezone?.getOffsetFromUTC())!
            }).forEach({
                if $0.id == DTUserDefaults.homeTimeId{
                    homeCity.append($0)
                } else {
                    worldClockArray.append($0)
                }
            })
        } else {
            print("We have a selected order")
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
                            homeCity.append(city)
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
        AppDelegate.getAppDelegate().setWorldClock(Array(worldClockArray))
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
}

extension WorldClockViewController:TableViewReorderDelegate{
    func tableView(_ tableView: UITableView, canReorderRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, reorderRowAt s: IndexPath, to d: IndexPath) {
        if s.section > d.section {
            let city = worldClockArray[s.row]
            homeCity.insert(city, at: d.row)
            worldClockArray.remove(at: s.row)
            DTUserDefaults.homeTimeId = city.id
        } else if d.section > s.section {
            let city = homeCity[s.row]
            worldClockArray.insert(city, at: d.row)
            homeCity.remove(at: s.row)
            DTUserDefaults.homeTimeId = -1
        } else {
            let destination =  s.row
            let source =   d.row
            (worldClockArray[source], worldClockArray[destination]) = (worldClockArray[destination], worldClockArray[source])
            DTUserDefaults.selectedCityOrder = worldClockArray.map({ $0.id })
            self.updateWorldClockArrayWithOrder(reload: true)
        }
        print("\(homeCity.count)")
        print("\(worldClockArray.count)")
    }
    
}
