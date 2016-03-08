//
//  PresetTableViewController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/3.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

protocol AddPresetDelegate {
    func onAddPresetNumber(number:Int,name:String)

}

class GoalTableViewController: UITableViewController,ButtonManagerCallBack,AddPresetDelegate {
        
    @IBOutlet weak var goalView: GoalView!
    var prestArray:[Presets] = []

    init() {
        super.init(nibName: "PresetTableViewController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        goalView.bulidPresetView(self.navigationItem,delegateB: self)

        let array:NSArray = Presets.getAll()
        for pArray in array {
            prestArray.append(pArray as! Presets)
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - AddPresetDelegate
    func onAddPresetNumber(number:Int,name:String){
        NSLog("onAddPresetNumber:\(number),name:\(name)")
        let prestModel:Presets = Presets(keyDict: ["id":0,"steps":number,"label":"\(name)","status":true])
        prestModel.add { (id, completion) -> Void in
            prestModel.id = id!
            self.prestArray.append(prestModel)
            self.tableView.reloadData()
        }
    }

    // MARK: - ButtonManagerCallBack
    func controllManager(sender:AnyObject){
        if(sender.isEqual(goalView.leftButton)){
            //let removeAll:Bool = Presets.removeAll()
            let addPreset:AddGoalViewController = AddGoalViewController()
            addPreset.addDelegate = self
            self.navigationController?.pushViewController(addPreset, animated: true)
        }

        if(sender.isKindOfClass(UISwitch.classForCoder())){
            let switchSender:UISwitch = sender as! UISwitch
            let preModel:Presets = prestArray[switchSender.tag]
            preModel.status = switchSender.on
            let isUpdate:Bool = preModel.update()
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return prestArray.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        return goalView.getPresetTableViewCell(indexPath, tableView: tableView,goalArray: prestArray, delegate: self)
    }


    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            let preModel:Presets = prestArray[indexPath.row]
            let isUpdate:Bool = preModel.remove()
            prestArray.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }

    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
}