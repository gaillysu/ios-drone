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
    var babyCockroaches: [(number:Int, coordinates:CoordinateSet)] = []
    
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
        newInstruction.coordinateSeries.append(contentsOf: self.coordinateSeries)
        newInstruction.startTime = self.startTime!
        newInstruction.stopTime = self.startTime!
        newInstruction.name = header!.instructionNameEditTextField.text!
        newInstruction.totalAmountOfCockroaches = self.babyCockroaches.count
        let realm = try! Realm()
        try! realm.write {
            realm.add(newInstruction)
            let view = MRProgressOverlayView.showOverlayAdded(to: self.view, title:"Saved", mode: MRProgressOverlayViewMode.checkmark, animated: true)
            view.setTintColor(UIColor.getBaseColor())
            Timer.after(0.6.second) {
                view.dismiss(true)
                self.dismiss(animated: true, completion: nil)
            }
        }    
    }
}


extension AddInstructionViewController{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier){
            cell = dequeuedCell
        }else{
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
        }
            let cockroach = babyCockroaches[(indexPath as NSIndexPath).row]
            cell.textLabel?.text = "Sensor \(cockroach.number)"
            cell.detailTextLabel?.text = cockroach.coordinates.getString()
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return babyCockroaches.count
    }
}

extension AddInstructionViewController{
    
    fileprivate func initEventBus(){
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
            if let _ = self.timer {
                let isInSet:Bool =  self.coordinateSeries.contains(where: { (serie: (CoordinateSerie)) -> Bool in
                    serie.cockroachNumber == cockroachData.babyCockroachNumber
                })
                if isInSet{
                    for coordinateSerie in self.coordinateSeries {
                        if (coordinateSerie.cockroachNumber == cockroachData.babyCockroachNumber ){
                            coordinateSerie.coordinateSets.append(cockroachData.coordinates)
                            break;
                        }
                    }
                } else {
                    let coordinateSerie = CoordinateSerie()
                    coordinateSerie.cockroachNumber = cockroachData.babyCockroachNumber
                    coordinateSerie.coordinateSets.append(cockroachData.coordinates)
                    self.coordinateSeries.append(coordinateSerie)
                }
            }
        }
        
        SwiftEventBus.onMainThread(self, name:SWIFTEVENT_BUS_COCKROACHES_CHANGED) { (data) -> Void in
            let cockroachesChangedEvent = data.object! as! CockroachMasterChanged
            if !cockroachesChangedEvent.connected {
                if let _ = self.timer{
                    self.stopRecording()
                }
                Banner(title: "Cockroach got disconnected!", subtitle: nil, image: nil, backgroundColor: UIColor.red, didTapBlock: nil).show()
            }
            self.tableview.reloadData()
            // Just for verification purposes
        }
    }
}
