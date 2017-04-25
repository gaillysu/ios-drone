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
    fileprivate var time:(hour:Int,minute:Int)
    fileprivate let identifier:String = "WorldClockCell"
    fileprivate var worldClockArray: [City] = []
    fileprivate var homeCity: [City] = []
    fileprivate var localTimeOffsetToGmt: Float
    fileprivate let realm:Realm
    @IBOutlet weak var tableView: UITableView!
    
    init() {
        let date = Date()
        realm = try! Realm()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ZZZ"
        var timeZoneString = dateFormatter.string(from: date)
        if timeZoneString.contains("+"){
            timeZoneString = String(timeZoneString.characters.dropFirst())
        }
        let idx0 = timeZoneString.index(timeZoneString.startIndex, offsetBy: 0)
        let idx1 = timeZoneString.index(timeZoneString.startIndex, offsetBy: 2)
        let idx2 = timeZoneString.index(timeZoneString.startIndex, offsetBy: 4)
        
        let hours:String = timeZoneString[idx0..<idx1]
        let minutes:String = timeZoneString[idx1..<idx2]
        let offsetHours = Float(hours)
        let offsetMinutes = Int(minutes)
        localTimeOffsetToGmt = offsetHours!
        if offsetMinutes! > 0 {
            localTimeOffsetToGmt += 0.5
        }
        time.hour = Calendar.current.component(.hour, from: date)
        time.minute = Calendar.current.component(.minute, from: date)
        super.init(nibName: "WorldClockViewController", bundle: Bundle.main)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: identifier,bundle: Bundle.main), forCellReuseIdentifier: identifier)
        tableView.reorder.delegate = self
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        self.dateLabel.text = "\(formatter.string(from: Date()))"
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
            return 1
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
            let city:City = worldClockArray[(indexPath as NSIndexPath).row - 1]
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
        let cell:WorldClockCell = tableView.dequeueReusableCell(withIdentifier: identifier) as! WorldClockCell
        cell.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: cell.frame.height)
        if (indexPath.row == 0 && indexPath.section == 0){
            let now = Date()
            let timeZoneNameData = DateFormatter.localCityName()
            if timeZoneNameData.isEmpty {
                cell.cityLabel.text = timeZoneNameData
            }
            cell.timeDescription.text = "Now"
            var minuteString:String = String(now.minute)
            if (now.minute < 10){
                minuteString = "0\(now.minute)"
            }
            cell.time.text = "\(now.hour):\(minuteString)"
            return cell
        }
        
        var city:City?
        if indexPath.section == 1{
            city = homeCity[indexPath.row]
        }else if indexPath.section == 2{
            city = worldClockArray[indexPath.row]
        }
        
        cell.cityLabel.text = city?.name
        var foreignTimeOffsetToGmt:Float = 0.0
        if let timezone:Timezone = city?.timezone{
            foreignTimeOffsetToGmt = Float(timezone.getOffsetFromUTC())/60
        }
        
        var text:String = ""
        if foreignTimeOffsetToGmt == localTimeOffsetToGmt  {
            text+="Today"
            cell.time.text = "\(time.hour):\(time.minute < 10 ? "0":"")\(time.minute)"
        }else if foreignTimeOffsetToGmt > localTimeOffsetToGmt{
            let timeAhead = foreignTimeOffsetToGmt - localTimeOffsetToGmt
            let halfAheadHour = timeAhead.truncatingRemainder(dividingBy: 1.0)
            
            var foreignTime:(hour:Int,minute:Int) = (hour:self.time.hour+Int(timeAhead), minute: (halfAheadHour == 0.5 ? self.time.minute + 30 :self.time.minute))
            if foreignTime.minute > 59 {
                foreignTime.minute-=59
                foreignTime.hour+=1
            }
            let hour:String = Int(timeAhead) == 1 ? "hour" : "hours"
            let halfHour :String = timeAhead.truncatingRemainder(dividingBy: 1.0) > 0.0 ? " and 30 minutes " : " "
            if foreignTime.hour > 23 {
                foreignTime.hour-=23
                text+="Tomorrow, \(Int(timeAhead)) \(hour)\(halfHour)ahead"
            }else{
                text+="Today, \(Int(timeAhead)) \(hour)\(halfHour)ahead"
            }
            cell.time.text = "\(foreignTime.hour):\(foreignTime.minute < 10 ? "0":"")\(foreignTime.minute)"
        }else if foreignTimeOffsetToGmt < localTimeOffsetToGmt{
            let timeBehind = foreignTimeOffsetToGmt - localTimeOffsetToGmt
            let halfHourBehind = timeBehind.truncatingRemainder(dividingBy: 1.0)
            var foreignTime:(hour:Int,minute:Int) = (hour:self.time.hour+Int(timeBehind), minute: (abs(halfHourBehind) == 0.5 ? self.time.minute - 30 :self.time.minute))
            if foreignTime.minute < 0 {
                foreignTime.minute+=59
                foreignTime.hour-=1
            }
            let hour:String = Int(timeBehind) == 1 ? "hour" : "hours"
            let halfHour :String = abs(timeBehind).truncatingRemainder(dividingBy: 1.0) > 0.0 ? " and 30 minutes " : " "
            if foreignTime.hour < 0 {
                foreignTime.hour+=24
                text+="Yesterday, \(Int(timeBehind)) \(hour)\(halfHour)behind"
            }else{
                text+="Today, \(Int(timeBehind)) \(hour)\(halfHour)behind"
            }
            cell.time.text = "\(foreignTime.hour):\(foreignTime.minute < 10 ? "0":"")\(foreignTime.minute)"
        }
        cell.timeDescription.text = text
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
