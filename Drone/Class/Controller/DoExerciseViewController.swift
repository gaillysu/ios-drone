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
import MRProgress
import SceneKit

class DoExerciseViewController: BaseViewController, UITableViewDataSource{
    
    let cellIdentifier: String = "cellIdentifier"
    var listenToEvents = false
    var timedSeconds = 0
    
    @IBOutlet weak var sceneview: SCNView!
    var human:Human?
    
    var instruction: Instruction?
    var header:DoExerciseHeader?
    var algorithm:MovementMatchingAlgorithm?
    weak var timer = Timer()
    
    @IBOutlet weak var sceneView: UIView!
    var cockroaches: [MasterCockroach] = []
    var completedDates: [Date] = []
  

    
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
        algorithm = MovementMatchingAlgorithm(withInstruction: self.instruction!, repCompleteCallback: { () in
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.header?.repititionLabel.text = "Amount of repetitions: \(self.algorithm!.finishedRepetitions)"
            self.header?.statusLabel.text =  "Repetition Done! Take a rest for 2 seconds"
            self.listenToEvents = false
            self.completedDates.append(Date())
            self.tableview.reloadData()
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timerSecondTriggeredAction), userInfo: nil, repeats: true)
            }, threshold: 30, amountFailedMovements: 7)
        
        algorithm?.setEqualCallback {
            if self.listenToEvents {
                let string:String = (self.header?.statusLabel.text!)!
                self.header?.statusLabel.text =  "\(string)!"
            }
        }
        algorithm?.setResetCallback {
            self.header?.statusLabel.text = "Too bad. Try again! Restart in 2 seconds"
            self.listenToEvents = false
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timerSecondTriggeredAction), userInfo: nil, repeats: true)
        }
        
        header?.exerciseNameLabel.text = "Exercise name: \(instruction!.name)"
        header?.statusLabel.text = "Ready?"
        header?.repititionLabel.text = "Amount of repetitions: 0 "
        initEventBus()
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerSecondTriggeredAction), userInfo: nil, repeats: true)
        initHuman()
    }
    
    func timerSecondTriggeredAction(){
        timedSeconds = timedSeconds +  1
        self.header?.statusLabel.text = "Starting in \((3 - timedSeconds))"
        if timedSeconds >= 3 {
            self.listenToEvents = true
            self.timedSeconds = 0
            self.header?.statusLabel.text = "Status: Try to replicate the movement!"
            if let timer = self.timer{
                timer.invalidate()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func saveExercise(){
        let realm = try! Realm()
        let exercise = Exercise()
        exercise.finishedRepetitions = (self.algorithm?.finishedRepetitions)!
        exercise.instruction = self.instruction!
        exercise.exerciseDate = Date()
        try! realm.write {
            realm.add(exercise)
            let view = MRProgressOverlayView.showOverlayAdded(to: self.view, title:"Saved", mode: MRProgressOverlayViewMode.checkmark, animated: true)!
            view.setTintColor(UIColor.getBaseColor())
            Timer.after(0.6.second) {
                view.dismiss(true)
                self.close()
            }
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
        if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            cell = dequeuedCell
        } else {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
        }
        
        if indexPath.section == 0 {
            let now = self.completedDates[indexPath.row]
            cell.textLabel?.text = "\(now.hour):\(now.minute):\(now.second) - \(now.day)/\(now.month)"
            cell.detailTextLabel?.text = ""
        } else {
            let masterCockroach = self.cockroaches[indexPath.section - 1]
            let babyCockroach = masterCockroach.getBabyCockroach(at: indexPath.row)
            cell.textLabel?.text = "Sensor \(babyCockroach.number)"
            cell.detailTextLabel?.text = babyCockroach.coordinateSet?.getString1()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if let _ = self.algorithm{
                return self.completedDates.count
            }
            return 0
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
    func initHuman(){
        let scnScene = SCNScene()
        sceneview.scene = scnScene
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
        sceneview.showsStatistics = true
        sceneview.autoenablesDefaultLighting = true
    }
}

extension DoExerciseViewController{
    fileprivate func initEventBus(){
        _ = SwiftEventBus.onMainThread(self, name:SWIFTEVENT_BUS_COCKROACHES_DATA_UPDATED) { (data) -> Void in
            let object = data.object! as! CockroachMasterDataReceived
            if let human = self.human{
//                human.rotateLeftArm(withCoordinates: object.coordinates)
            }
            for cockroach in self.cockroaches {
                if cockroach.address == object.address{
                    cockroach.addOrUpdateBabyCockroach(byCockroachMasterDataReceived: object)
                    self.updateAlgorithm(cockroachData: object)
                    return
                }
            }
            self.cockroaches.append(MasterCockroach(WithMasterCockroachData: object))
            self.updateAlgorithm(cockroachData: object)
        }
        
       _ = SwiftEventBus.onMainThread(self, name:SWIFTEVENT_BUS_COCKROACHES_CHANGED) { (data) -> Void in
            let cockroachesChangedEvent = data.object! as! CockroachMasterChanged
            if !cockroachesChangedEvent.connected {
                Banner(title: "Sensor got disconnected!", subtitle: nil, image: nil, backgroundColor: UIColor.red, didTapBlock: nil).show()
            }
            self.tableview.reloadData()
        }
    }
    
    private func updateAlgorithm(cockroachData: CockroachMasterDataReceived){
        if listenToEvents {
            self.algorithm?.addMovement(byMasterCockroachData: cockroachData)
        }
        self.tableview.reloadData()
    }
}
