                  //
//  PhysioViewController.swift
//  Drone
//
//  Created by Karl-John on 26/8/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import UIKit
import RealmSwift

class PhysioViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource{

    let cellIdentifier:String = "cellIdentifier"
    let headerIdentifier:String = "headerIdentifier"
    var exercises:Results<Exercise>?
    var instructions:Results<Instruction>?
    var exercisesViewModel:[PhysioViewModel] = []
    var instructionsViewModel:[PhysioViewModel] = []
    let realm = try! Realm()
    
    @IBOutlet weak var exerciseTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Physiotherapy"
        self.addPlusButton(#selector(add))
        self.exercises = realm.objects(Exercise.self)
        self.instructions = realm.objects(Instruction.self)
        self.getAppDelegate().connectCockroach()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func add(){
        if self.getAppDelegate().getConnectedCockroaches().count == 0 {
            self.showNoCockroachConnectedDialog()
        }else{
            self.present(self.makeStandardUINavigationController(AddInstructionViewController()), animated: true, completion: nil)
        }
    }
    
    fileprivate func showNoCockroachConnectedDialog(){
        let chooseAction = UIAlertController(title: "No cockroaches connected", message: "Why don't you connect a cockroach before getting started?", preferredStyle: UIAlertControllerStyle.alert)
        let connectAction:UIAlertAction = UIAlertAction(title: "Connect", style: UIAlertActionStyle.default) { (action:UIAlertAction) -> Void in
            self.present(self.makeStandardUINavigationController(PhysioDeviceViewController()), animated: true, completion: nil)
        }
        let cancelAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel, handler: nil)
        chooseAction.addAction(connectAction)
        chooseAction.addAction(cancelAction)
        self.present(chooseAction, animated: true, completion:nil)
    }
}

// UITableViewDelegate & Datasource
extension PhysioViewController{
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.exerciseTableView.reloadData()
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Instructions"
        case 1:
            return "Past Exercises"
        default:
            return "Unknown"
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var header:UITableViewHeaderFooterView
        if let dequeuedHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerIdentifier){
            header = dequeuedHeader
        }else{
            header = UITableViewHeaderFooterView(reuseIdentifier: headerIdentifier)
        }
        switch section {
        case 0:
            header.textLabel?.text = "Instructions"
            break;
        case 1:
            header.textLabel?.text = "Past Exercises"
            break;
        default:
            header.textLabel?.text = "Unknown"
            break;
        }
        return header
    }
    
    @objc(tableView:commitEditingStyle:forRowAtIndexPath:) func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let instruction:Instruction = self.instructions![(indexPath as NSIndexPath).row]
            try! realm.write({
                realm.delete(instruction)
            })
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    @objc(tableView:editActionsForRowAtIndexPath:) func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let button1 = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
            self.tableView(tableView, commit: .delete, forRowAt: indexPath)
        })
        button1.backgroundColor = UIColor.getTintColor()
        return [button1]
    }

    
    @objc(tableView:canEditRowAtIndexPath:) func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch (indexPath as NSIndexPath).section {
        case 0:
            return true
        default:
            return false
        }
    }
    
    @objc(tableView:cellForRowAtIndexPath:) func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier){
            cell = dequeuedCell
        }else{
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
        }
        switch indexPath.section {
        case 0:
            let instruction = self.instructions![indexPath.row]
            cell.textLabel?.text = "Name: \(instruction.name), amount of sensors required: \(instruction.totalAmountOfCockroaches)"
            cell.detailTextLabel?.text = "Created on \(instruction.createdDate.day)/\(instruction.createdDate.month)"
            break
        case 1:
            let exercise = self.exercises![indexPath.row]
            if let instruction = exercise.instruction {
                cell.textLabel?.text = "Name: \(instruction.name), amount of reps done: \(exercise.finishedRepetitions)"
            }else{
                cell.textLabel?.text = "Name: EXERCISE DELETED, amount of reps done: \(exercise.finishedRepetitions)"
            }
            
            cell.detailTextLabel?.text = "Exercise finished on \(exercise.exerciseDate.day)/\(exercise.exerciseDate.month)"
            break
        default:
                break
        }
        return cell
    }
    
    @objc(tableView:didSelectRowAtIndexPath:) func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if self.getAppDelegate().getConnectedCockroaches().count == 0 {
            self.showNoCockroachConnectedDialog()
        }else{
            if indexPath.section == 0 {
                let doExerciseViewController = DoExerciseViewController()
                doExerciseViewController.instruction = self.instructions![(indexPath as NSIndexPath).row]
                self.present(self.makeStandardUINavigationController(doExerciseViewController), animated: true, completion: nil)
            }
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    @objc(numberOfSectionsInTableView:) func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            switch section {
            case 0:
                return (self.instructions?.count)!
            case 1:
                return (self.exercises?.count)!
            default:
                return 0
            }
    }
    
}
