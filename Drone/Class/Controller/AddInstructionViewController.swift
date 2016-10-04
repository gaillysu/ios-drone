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
import SceneKit

class AddInstructionViewController: BaseViewController, UITableViewDataSource {

    @IBOutlet var tableview: UITableView!
    
    var header:AddInstructionHeader?;
    
    @IBOutlet weak var sceneView: SCNView!
    let cellIdentifier:String = "cellIdentifier"
    var cockroaches: [MasterCockroach] = []
    var human:Human?
    weak var timer = Timer()
    let positions:[CockroachPositionProtocol] = [NormalPosition(),StandingPosition(),StandingLeftPosition(),StandingRightPosition(),StandingUpsideDown(),UpsideDownPosition()]
    fileprivate var startTime:Date?
    fileprivate var stopDate:Date?
    
    var pointOffset: (x:Int,y:Int,z:Int) = (0,0,0)
    var pointOffsetEnabled = false
    var currentPosition:(x:CGFloat,y:CGFloat,z:CGFloat) = (0.0,0.0,0.0)
    
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
        header?.addActionToButton(self,startRecordingSelector: #selector(self.startRecording), stopRecordingSelector: #selector(self.stopRecording), resetDummySelector: #selector(self.resetDummy))
        header!.amountOfSensorLabel.text = "Amount of sensors: \(getAppDelegate().getConnectedCockroaches().count)"
        initEventBus()
        initHuman()
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
    
    func resetDummy(){
        self.pointOffsetEnabled = true
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
        let babyCockroach = cockroach.getBabyCockroach(at: 0)
        return PhysioCellGenerator.getCellFrom(cockroach: babyCockroach.number, coordinates: babyCockroach.coordinateSet!, tableview: tableView, dequeueIdentifier: self.cellIdentifier, numberCoordinate: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !self.cockroaches.isEmpty {
            return self.cockroaches[section].getAmountBabies() * 3
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
    func initHuman(){
        let scnScene = SCNScene()
        sceneView.scene = scnScene
        scnScene.background.contents = "Human.scnassets/Background_Diffuse.png"
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 60)
        cameraNode.camera?.xFov = 60
        cameraNode.camera?.yFov  = 60
        cameraNode.camera?.zFar = 1000
        cameraNode.camera?.zNear = 0.01
        scnScene.rootNode.addChildNode(cameraNode)
        self.human = Human()
        scnScene.rootNode.addChildNode(human!)
        sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = true
    }
}

extension AddInstructionViewController{
    private func updateCoordinatesAndHuman(x:CGFloat, y:CGFloat, z:CGFloat){
        if let human = self.human{
            human.rotateLeftArm(x: x, y: y, z:z)
        }
    }
    
    fileprivate func initEventBus(){
        _ = SwiftEventBus.onMainThread(self, name:SWIFTEVENT_BUS_COCKROACHES_DATA_UPDATED) { (data) -> Void in
            let object = data.object! as! CockroachMasterDataReceived
            var found = false
            let x = object.coordinates.X1
            let y = object.coordinates.Y1
            let z = object.coordinates.Z1
            
            
            if self.pointOffsetEnabled {
                self.pointOffsetEnabled = false
                self.pointOffset = (x: x * -1, y: y * -1, z:z * -1)
            }
            
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
            
            for position in self.positions {
                if position.matchesPosition(coordinationSet: object.coordinates, whichCoordinate: 1){
                    let coordinates = position.getCoordinatesForHuman()
                    if self.currentPosition != coordinates {
                        print("Update.")
                        print(position.getDiscription())
                        self.currentPosition = coordinates
                        self.updateCoordinatesAndHuman(x: coordinates.x, y: coordinates.y, z: coordinates.z)
                    }
                    return
                }
            }
            
            if let _ = self.timer {
                let isInSet:Bool =  self.coordinateSeries.contains(where: { (serie: (CoordinateSerie)) -> Bool in
                    return serie.cockroachNumber == object.babyCockroachNumber
                })
                if isInSet {
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
