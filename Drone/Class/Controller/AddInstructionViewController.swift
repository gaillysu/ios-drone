//
//  AddInstructionViewController.swift
//  Drone
//
//  Created by Karl-John on 29/8/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import BRYXBanner
import SwiftEventBus
import Timepiece
import UIKit

class AddInstructionViewController: BaseViewController, UITableViewDataSource {

    @IBOutlet var tableview: UITableView!
    
    var header:AddInstructionHeader?;
    
    let cellIdentifier:String = "cellIdentifier"
    var babyCockroaches: [(number:Int, coordinates:CoordinateSet)] = []
    
    weak var timer = NSTimer()
    
    private var startTime:NSDate?
    private var stopDate:NSDate?
    
    private var coordinateSeries:[CoordinateSerie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "New Instruction"
        self.addCloseButton(#selector(close))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(saveInstruction))
        header = UIView.loadFromNibNamed("AddInstructionHeader") as? AddInstructionHeader
        header!.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, header!.frame.height)
        let headerView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, header!.frame.height))
        headerView.addSubview(header!)
        tableview.tableHeaderView = headerView
        header?.addActionToButton(self,startRecordingSelector: #selector(self.startRecording), stopRecordingSelector: #selector(self.stopRecording))
        header!.amountOfSensorLabel.text = "Amount of sensors: \(getAppDelegate().getConnectedCockroaches().count)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func close() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func startRecording() {
        header!.startRecordToggle()
        startTime = NSDate()
        setStopwatch(0, seconds: 0)
        self.coordinateSeries.removeAll(keepCapacity: false)
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(timerSecondTriggeredAction), userInfo: nil, repeats: true)
    }
    
    func stopRecording() {
        header!.stopRecordToggle()
        timer!.invalidate()
        stopDate = NSDate()
    }
    
    func timerSecondTriggeredAction(){
        let totalSeconds = NSDate().timeIntervalSinceDate(startTime!)
        let minutes = Int((totalSeconds / 60) % 60)
        let seconds = Int(totalSeconds % 60)
        setStopwatch(minutes, seconds: seconds)
    }

    private func setStopwatch(minutes:Int,seconds:Int){
        header!.recordedTimeLabel.text = String(format: "%02d:%02d",minutes,seconds)
    }

    func saveInstruction(){
        var banner: Banner?
        if self.coordinateSeries.isEmpty {
            banner = Banner(title: "Nothing recorded", subtitle: nil, image: nil, backgroundColor: UIColor.redColor(), didTapBlock: nil)
        }
        if ((header!.instructionNameEditTextField.text?.isEmpty) != nil){
            banner = Banner(title: "No instruction name", subtitle: nil, image: nil, backgroundColor: UIColor.redColor(), didTapBlock: nil)
        }
        if let unpackedBanner = banner{
            unpackedBanner.show()
            return
        }
    }
}


extension AddInstructionViewController{
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        if let dequeuedCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier){
            cell = dequeuedCell
        }else{
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: cellIdentifier)
        }
            let cockroach = babyCockroaches[indexPath.row]
            cell.textLabel?.text = "Sensor \(cockroach.number)"
            cell.detailTextLabel?.text = cockroach.coordinates.getString()
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return babyCockroaches.count
    }
}

extension AddInstructionViewController{
    private func initEventBus(){
        SwiftEventBus.onMainThread(self, name:SWIFTEVENT_BUS_COCKROACHES_DATA_UPDATED) { (data) -> Void in
            let cockroachData = data.object! as! CockroachMasterDataReceived
            for var cockroach in self.babyCockroaches {
                if cockroachData.babyCockroachNumber == cockroach.number {
                    cockroach.coordinates = cockroachData.coordinates
                    break
                }
            }
            self.tableview.reloadData()
            if let _ = self.timer {
                let isInSet:Bool =  self.coordinateSeries.contains({ (serie: (CoordinateSerie)) -> Bool in
                    serie.address == cockroachData.address
                })
                if isInSet{
                    for coordinateSerie in self.coordinateSeries {
                        if (coordinateSerie.address == cockroachData.address ){
                            coordinateSerie.coordinateSets.append(cockroachData.coordinates)
                            break;
                        }
                    }
                } else {
                    let coordinateSerie = CoordinateSerie()
                    coordinateSerie.address = cockroachData.address.UUIDString
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
                Banner(title: "Cockroach got disconnected!", subtitle: nil, image: nil, backgroundColor: UIColor.redColor(), didTapBlock: nil).show()
                
                
            }
            self.tableview.reloadData()
            // Just for verification purposes
        }
    }
}