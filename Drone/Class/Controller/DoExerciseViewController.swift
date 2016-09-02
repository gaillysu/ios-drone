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

    var babyCockroaches: [(number:Int, coordinates:CoordinateSet)] = []
    var completedCoordinatesSerie: [Int : (completedSeries:Int, skippedMovements:Int)] = [:]
    
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Do Exercise!"
        self.addCloseButton(#selector(close))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(saveExercise))
        self.navigationItem.rightBarButtonItem?.enabled = false
        header = UIView.loadFromNibNamed("DoExerciseHeader") as? DoExerciseHeader
        header!.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, header!.frame.height)
        let headerView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, header!.frame.height))
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
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension DoExerciseViewController{
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        if let dequeuedCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier){
            cell = dequeuedCell
        }else{
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: cellIdentifier)
        }
        switch indexPath.section {
        case 0:
            break
        case 1:
            let cockroach = babyCockroaches[indexPath.row]
            cell.textLabel?.text = "Sensor \(cockroach.number)"
            cell.detailTextLabel?.text = cockroach.coordinates.getString()
            break
        default:
            break;
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.finishedRepetitions
        case 1:
            return babyCockroaches.count
        default:
            return 0
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Completed set"
        case 1:
            return "Sensors"
        default:
            return "Unknown section"
        }
    }
}

extension DoExerciseViewController{
    private func initEventBus(){
        SwiftEventBus.onMainThread(self, name:SWIFTEVENT_BUS_COCKROACHES_DATA_UPDATED) { (data) -> Void in
            let cockroachData = data.object! as! CockroachMasterDataReceived
            if self.babyCockroaches.isEmpty {
                self.babyCockroaches.append((number: cockroachData.babyCockroachNumber, coordinates: cockroachData.coordinates))
            }else{
                for i in 0..<self.babyCockroaches.count {
                    if cockroachData.babyCockroachNumber == self.babyCockroaches[i].number {
                        self.babyCockroaches[i].coordinates = cockroachData.coordinates
                        break
                    }
                }
            }
            self.tableview.reloadData()
            
            if self.completedCoordinatesSerie.count == 0 {
                for coordinateSerie in (self.instruction?.coordinateSeries)!{
                    if cockroachData.babyCockroachNumber == coordinateSerie.cockroachNumber {
                        if(cockroachData.coordinates.equal(coordinateSerie.coordinateSets[0])){
                            print("Close enough for the first add")
                            self.completedCoordinatesSerie[cockroachData.babyCockroachNumber] = (completedSeries:1, skippedMovements:0)
                        }
                    }
                }
            }else{
                for i in 0..<self.instruction!.coordinateSeries.count {
                    let coordinateSerie = (self.instruction?.coordinateSeries)![i]
                    if cockroachData.babyCockroachNumber == coordinateSerie.cockroachNumber {
                        if(cockroachData.coordinates.equal(coordinateSerie.coordinateSets[coordinateSerie.cockroachNumber])){
                            print("Close enough for the add")
                            var data = self.completedCoordinatesSerie[cockroachData.babyCockroachNumber]!
                            if (data.completedSeries + data.skippedMovements) >= coordinateSerie.coordinateSets.count{
                                data.completedSeries = 0
                                data.skippedMovements = 0
                                print("Reset Cuz of good stuff!")
                            }else{
                                data.completedSeries += 1
                                if(data.completedSeries == coordinateSerie.coordinateSets.count){
                                    print("Wow holy shit!")
                                    data.completedSeries = 0
                                    data.skippedMovements = 0
                                    self.finishedRepetitions += 1
                                    self.header?.repititionLabel.text = "Amount of repetitions: \(self.finishedRepetitions) "
                                }
                            }
                        }else{
                            var data = self.completedCoordinatesSerie[cockroachData.babyCockroachNumber]!
                            print("Not good enough unfortunately")
                            if data.skippedMovements >= 3 {
                                print("Done, no go.")
                                data.completedSeries = 0
                                data.skippedMovements = 0
                            }
                        }
                    }
                }
            }
        }
        
        SwiftEventBus.onMainThread(self, name:SWIFTEVENT_BUS_COCKROACHES_CHANGED) { (data) -> Void in
            let cockroachesChangedEvent = data.object! as! CockroachMasterChanged
            if !cockroachesChangedEvent.connected {
                Banner(title: "Cockroach got disconnected!", subtitle: nil, image: nil, backgroundColor: UIColor.redColor(), didTapBlock: nil).show()
            }
            self.tableview.reloadData()
        }
    }
}