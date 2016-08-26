//
//  PhysioViewController.swift
//  Drone
//
//  Created by Karl-John on 26/8/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import UIKit
import RealmSwift

class PhysioViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

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
        let button: UIButton = UIButton(type: UIButtonType.Custom)
        button.setImage(UIImage(named: "addbutton"), forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(add), forControlEvents: UIControlEvents.TouchUpInside)
        button.frame = CGRectMake(0, 0, 30, 30)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
        let realm = try! Realm()
        self.exercises = realm.objects(Exercise)
        self.instructions = realm.objects(Instruction)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func add(){
        let chooseAction = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let addExerciseAction:UIAlertAction = UIAlertAction(title: "Add Exercise", style: UIAlertActionStyle.Default) { (action:UIAlertAction) -> Void in
            
        }
        
        let doExerciseAction:UIAlertAction = UIAlertAction(title: "Do Exercise", style: UIAlertActionStyle.Default) { (action:UIAlertAction) -> Void in
            
        }
        let alertAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil)
        chooseAction.addAction(addExerciseAction)
        chooseAction.addAction(doExerciseAction)
        chooseAction.addAction(alertAction)
        
        self.presentViewController(chooseAction, animated: true, completion:nil)
    }
}


// UITableViewDelegate & Datasource
extension PhysioViewController{
    
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
            header.textLabel?.text = "Exercises"
            break;
        default:
            header.textLabel?.text = "Unknown"
            break;
            
        }
        print(section);
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
        return 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
}
