//
//  DoExerciseViewController.swift
//  Drone
//
//  Created by Karl-John on 29/8/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import UIKit

class DoExerciseViewController: UIViewController, UITableViewDataSource{

    
    var instruction: Instruction?
    let cellIdentifier: String = "cellIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad() 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Sensors"
        case 1:
            return "Completed set"
        default:
            return "Unknown section"
        }
    }
}
