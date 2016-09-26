//
//  AddInstructionViewController.swift
//  Drone
//
//  Created by Karl-John on 29/8/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import RealmSwift
import MRProgress
import BRYXBanner
import SwiftEventBus
import Timepiece
import UIKit

class AddInstructionViewController: BaseViewController, UITableViewDataSource {

    @IBOutlet var tableview: UITableView!
    
    var header:AddInstructionHeader?;
    
    let cellIdentifier:String = "cellIdentifier"
    var cockroaches: [MasterCockroach] = []
    
    weak var timer = Timer()
    
    fileprivate var startTime:Date?
    fileprivate var stopDate:Date?
    
    fileprivate var coordinateSeries:[CoordinateSerie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "New Instruction"
        self.addCloseButton(#selector(close))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.plain, target: self, action: #selector(saveInstruction))
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        header = UIView.loadFromNibNamed("AddInstructionHeader") as? AddInstructionHeader
        header!.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: header!.frame.height)
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: header!.frame.height))
        headerView.addSubview(header!)
        tableview.tableHeaderView = headerView
        header?.addActionToButton(self,startRecordingSelector: #selector(self.startRecording), stopRecordingSelector: #selector(self.stopRecording))
        header!.amountOfSensorLabel.text = "Amount of sensors: \(getAppDelegate().getConnectedCockroaches().count)"
        initEventBus()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func close() {
        SwiftEventBus.unregister(self)
        self.dismiss(animated: true, completion: nil)
    }
    
    func startRecording() {
        header!.startRecordToggle()
        startTime = Date()
        setStopwatch(0, seconds: 0)
        self.coordinateSeries.removeAll(keepingCapacity: false)
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerSecondTriggeredAction), userInfo: nil, repeats: true)
    }
    
    func stopRecording() {
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        header!.stopRecordToggle()
        timer!.invalidate()
        stopDate = Date()
    }
    
    func timerSecondTriggeredAction(){
        let totalSeconds = Date().timeIntervalSince(startTime!)
        let minutes = Int((totalSeconds / 60).truncatingRemainder(dividingBy: 60))
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        setStopwatch(minutes, seconds: seconds)
    }

    fileprivate func setStopwatch(_ minutes:Int,seconds:Int){
        header!.recordedTimeLabel.text = String(format: "%02d:%02d",minutes,seconds)
    }

    func saveInstruction(){
        
        if header!.instructionNameEditTextField.text == "" {
            Banner(title: "No instruction name", subtitle: nil, image: nil, backgroundColor: UIColor.red, didTapBlock: nil).show()
            return
        }
        let newInstruction = Instruction()
        for coordinateSerie in self.coordinateSeries{
            newInstruction.coordinateSeries.append(coordinateSerie)
        }
        
        newInstruction.startTime = self.startTime!
        newInstruction.stopTime = self.startTime!
        newInstruction.name = header!.instructionNameEditTextField.text!
        newInstruction.totalAmountOfCockroaches = self.cockroaches[0].getAmountBabies()
        let realm = try! Realm()
        try! realm.write {
            realm.add(newInstruction)
            let view = MRProgressOverlayView.showOverlayAdded(to: self.view, title:"Saved", mode: MRProgressOverlayViewMode.checkmark, animated: true)!
            view.setTintColor(UIColor.getBaseColor())
            Timer.after(0.6.second) {
                view.dismiss(true)
                self.dismiss(animated: true, completion: nil)
                SwiftEventBus.unregister(self)
            }
        }    
    }
}



extension AddInstructionViewController{
    
    @objc(tableView:cellForRowAtIndexPath:) func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cockroach = cockroaches[indexPath.section]
        let babyCockroach = cockroach.getBabyCockroach(at: indexPath.row)
        return PhysioCellGenerator.getCellFrom(cockroach: babyCockroach.number, coordinates: babyCockroach.coordinateSet!, tableview: tableView, dequeueIdentifier: self.cellIdentifier)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !self.cockroaches.isEmpty {
            return self.cockroaches[section].getAmountBabies()
        }
        return 0
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.cockroaches[section].address.uuidString
    }
    
    @objc(numberOfSectionsInTableView:) func numberOfSections(in tableView: UITableView) -> Int {
        return self.cockroaches.count
    }
}

extension AddInstructionViewController{
    fileprivate func initEventBus(){
        _ = SwiftEventBus.onMainThread(self, name:SWIFTEVENT_BUS_COCKROACHES_DATA_UPDATED) { (data) -> Void in
            let object = data.object! as! CockroachMasterDataReceived
            var found = false
            print(object.coordinates.getString())
            for cockroach in self.cockroaches {
                if cockroach.address == object.address{
                    cockroach.addOrUpdateBabyCockroach(byCockroachMasterDataReceived: object)
                    self.tableview.reloadData()
                    found = true
                }
            }
            if !found {
                self.cockroaches.append(MasterCockroach(WithMasterCockroachData: object))
                self.tableview.reloadData()
            }
            var sensors = 0
            for masterCockroach in self.cockroaches {
                sensors = sensors + masterCockroach.getAmountBabies()
            }
            self.header!.amountOfSensorLabel.text = "Amount of sensors: \(sensors)"
            if let _ = self.timer {
                let isInSet:Bool =  self.coordinateSeries.contains(where: { (serie: (CoordinateSerie)) -> Bool in
                    return serie.cockroachNumber == object.babyCockroachNumber
                })
                if isInSet{
                    for coordinateSerie in self.coordinateSeries {
                        if coordinateSerie.cockroachNumber == object.babyCockroachNumber {
                            coordinateSerie.coordinateSets.append(object.coordinates)
                            break;
                        }
                    }
                } else {
                    let coordinateSerie = CoordinateSerie()
                    coordinateSerie.cockroachNumber = object.babyCockroachNumber
                    coordinateSerie.coordinateSets.append(object.coordinates)
                    self.coordinateSeries.append(coordinateSerie)
                }
            }
            
        }
    }
}
