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
    
    @IBOutlet weak var exerciseTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Physiotherapy"
        self.addPlusButton(#selector(add))
        let realm = try! Realm()
        self.exercises = realm.objects(Exercise)
        self.instructions = realm.objects(Instruction)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func add(){
        if self.getAppDelegate().getConnectedCockroaches().count == 0 {
            let chooseAction = UIAlertController(title: "No cockroaches connected", message: "Why don't you connect a cockroach before getting started?", preferredStyle: UIAlertControllerStyle.Alert)
            let connectAction:UIAlertAction = UIAlertAction(title: "Connect", style: UIAlertActionStyle.Default) { (action:UIAlertAction) -> Void in
                self.presentViewController(self.makeStandardUINavigationController(PhysioDeviceViewController()), animated: true, completion: nil)
            }
            let cancelAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
            chooseAction.addAction(connectAction)
            chooseAction.addAction(cancelAction)
            self.presentViewController(chooseAction, animated: true, completion:nil)
        }else{
            self.presentViewController(self.makeStandardUINavigationController(AddInstructionViewController()), animated: true, completion: nil)
        }
    }
}

// UITableViewDelegate & Datasource
extension PhysioViewController{
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var header:UITableViewHeaderFooterView
        if let dequeuedHeader = tableView.dequeueReusableHeaderFooterViewWithIdentifier(headerIdentifier){
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        if let dequeuedCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier){
            cell = dequeuedCell
        }else{
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return (instructions?.count)!
        case 1:
            return (exercises?.count)!
        default:
            return 0
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
}
