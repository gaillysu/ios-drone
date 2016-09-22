//
//  DoExerciseViewController.swift
//  Drone
//
//  Created by Karl-John on 29/8/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import UIKit
import SwiftEventBus
import BRYXBanner
import RealmSwift

class DoExerciseViewController: BaseViewController, UITableViewDataSource{

    var finishedRepetitions: Int = 0
    var instruction: Instruction?
    let cellIdentifier: String = "cellIdentifier"
    var header:DoExerciseHeader?

    var cockroaches: [MasterCockroach] = []
    var completedCoordinatesSerie: [Int : (completedSeries:Int, skippedMovements:Int)] = [:]
    
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Do Exercise!"
        self.addCloseButton(#selector(close))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.plain, target: self, action: #selector(saveExercise))
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        header = UIView.loadFromNibNamed("DoExerciseHeader") as? DoExerciseHeader
        header!.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: header!.frame.height)
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: header!.frame.height))
        headerView.addSubview(header!)
        tableview.tableHeaderView = headerView

        header?.exerciseNameLabel.text = "Exercise name: \(instruction!.name)"
        header?.statusLabel.text = "Status: Go ahead, follow the instruction"
        header?.repititionLabel.text = "Amount of repetitions: 0 "
        initEventBus()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func saveExercise(){
        let realm = try! Realm()
        let exercise = Exercise()
        exercise.finishedRepetitions = self.finishedRepetitions
        exercise.instruction = self.instruction!
        try! realm.write {
            realm.add(exercise)
            
        }
    }
    
    func close() {
        SwiftEventBus.unregister(self)
        self.dismiss(animated: true, completion: nil)
    }
}

extension DoExerciseViewController{
    
    @objc(tableView:cellForRowAtIndexPath:) func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier){
            cell = dequeuedCell
        }else{
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
        }
        
        if indexPath.section == 0 {
            cell.textLabel?.text = "Nothing yet :)"
            cell.detailTextLabel?.text = ""
        } else {
            let masterCockroach = self.cockroaches[indexPath.section - 1]
            let babyCockroach = masterCockroach.getBabyCockroach(at: indexPath.row)
            cell.textLabel?.text = "Sensor \(babyCockroach.number)"
            cell.detailTextLabel?.text = babyCockroach.coordinateSet?.getString()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.finishedRepetitions
        }
        return self.cockroaches[section-1].getAmountBabies()
    }
    
    @objc(numberOfSectionsInTableView:) func numberOfSections(in tableView: UITableView) -> Int {
        return self.cockroaches.count + 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Completed set"
        }
        if self.cockroaches.isEmpty{
            return ""
        }
        return self.cockroaches[section - 1].address.uuidString
    }
}

extension DoExerciseViewController{
    fileprivate func initEventBus(){
        _ = SwiftEventBus.onMainThread(self, name:SWIFTEVENT_BUS_COCKROACHES_DATA_UPDATED) { (data) -> Void in
            let object = data.object! as! CockroachMasterDataReceived
            for cockroach in self.cockroaches {
                if cockroach.address == object.address{
                    cockroach.addOrUpdateBabyCockroach(byCockroachMasterDataReceived: object)
                    self.tableview.reloadData()
                    return
                }
            }
            self.cockroaches.append(MasterCockroach(WithMasterCockroachData: object))
            self.tableview.reloadData()
            if self.completedCoordinatesSerie.count == 0 {
                for coordinateSerie in (self.instruction?.coordinateSeries)!{
                    if object.babyCockroachNumber == coordinateSerie.cockroachNumber {
                        if(object.coordinates.equal(coordinateSerie.coordinateSets[0])){
                            print("Close enough for the first add")
                            self.completedCoordinatesSerie[object.babyCockroachNumber] = (completedSeries:1, skippedMovements:0)
                        }
                    }
                }
            }else{
                for i in 0..<self.instruction!.coordinateSeries.count {
                    let coordinateSerie = (self.instruction?.coordinateSeries)![i]
                    if object.babyCockroachNumber == coordinateSerie.cockroachNumber {
                        if(object.coordinates.equal(coordinateSerie.coordinateSets[coordinateSerie.cockroachNumber])){
                            print("Close enough for the add")
                            if let data = self.completedCoordinatesSerie[object.babyCockroachNumber]{
                                var unpackedData = self.completedCoordinatesSerie[object.babyCockroachNumber]!
                                if (unpackedData.completedSeries + data.skippedMovements) >= coordinateSerie.coordinateSets.count{
                                    unpackedData.completedSeries = 0
                                    unpackedData.skippedMovements = 0
                                    print("Reset Cuz of good stuff!")
                                }else{
                                    unpackedData.completedSeries += 1
                                    if(data.completedSeries == coordinateSerie.coordinateSets.count){
                                        print("Wow holy shit!")
                                        unpackedData.completedSeries = 0
                                        unpackedData.skippedMovements = 0
                                        self.finishedRepetitions += 1
                                        self.header?.repititionLabel.text = "Amount of repetitions: \(self.finishedRepetitions) "
                                    }
                                }
                                }
                        }else{
                            if let data = self.completedCoordinatesSerie[object.babyCockroachNumber]{
                                print("Not good enough unfortunately")
                                if data.skippedMovements >= 3 {
                                    print("Done, no go.")
                                    self.completedCoordinatesSerie[object.babyCockroachNumber]!.completedSeries = 0
                                    self.completedCoordinatesSerie[object.babyCockroachNumber]!.skippedMovements = 0
                                }
                            }
                        }
                    }
                }
            }
        }
        
        SwiftEventBus.onMainThread(self, name:SWIFTEVENT_BUS_COCKROACHES_CHANGED) { (data) -> Void in
            let cockroachesChangedEvent = data.object! as! CockroachMasterChanged
            if !cockroachesChangedEvent.connected {
                Banner(title: "Cockroach got disconnected!", subtitle: nil, image: nil, backgroundColor: UIColor.red, didTapBlock: nil).show()
            }
            self.tableview.reloadData()
        }
    }
}
