//
//  AddAlarmController.swift
//  Nevo
//
//  Created by leiyuncun on 15/11/27.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

protocol AddAlarmDelegate {

    func onDidAddAlarmAction(timer:NSTimeInterval,repeatStatus:Bool,name:String)

}

class AddAlarmController: UITableViewController,ButtonManagerCallBack {

    @IBOutlet weak var adTableView: AddAlarmView!
    var mDelegate:AddAlarmDelegate?

    var timer:NSTimeInterval = 0.0
    var repeatStatus:Bool = false
    var name:String = ""

    init() {
        super.init(nibName: "AddAlarmController", bundle: NSBundle.mainBundle())

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        adTableView.bulidAdTableView(self.navigationItem)

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: Selector("controllManager:"))
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func controllManager(sender:AnyObject) {
        if(sender.isKindOfClass(UISwitch.classForCoder())){
            
        }else{
            let indexPaths:NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
            let timerCell:UITableViewCell = self.tableView.cellForRowAtIndexPath(indexPaths)!
            for datePicker in timerCell.contentView.subviews{
                if(datePicker.isKindOfClass(UIDatePicker.classForCoder())){
                    let picker:UIDatePicker = datePicker as! UIDatePicker
                    timer = picker.date.timeIntervalSince1970
                    NSLog("UIDatePicker______%@,\(timer)", picker.date)

                }
            }

            let indexPaths2:NSIndexPath = NSIndexPath(forRow: 0, inSection: 1)
            let timerCell2:UITableViewCell = self.tableView.cellForRowAtIndexPath(indexPaths2)!
            for datePicker in timerCell2.contentView.subviews{
                if(datePicker.isKindOfClass(UISwitch.classForCoder())){
                    let repeatSwicth:UISwitch = datePicker as! UISwitch
                    repeatStatus = repeatSwicth.on
                    NSLog("repeatStatus______%@", repeatStatus)

                }
            }

            let indexPaths3:NSIndexPath = NSIndexPath(forRow: 1, inSection: 1)
            let timerCell3:UITableViewCell = self.tableView.cellForRowAtIndexPath(indexPaths3)!
            for datePicker in timerCell3.contentView.subviews{
                let labelView:UIView = datePicker as UIView
                if(labelView.tag == 1230){
                    let labelText:UILabel = labelView as! UILabel
                    name = labelText.text!
                    NSLog("name______%@", labelText.text!)
                }
            }
        }
        mDelegate?.onDidAddAlarmAction(timer, repeatStatus: repeatStatus, name: name)
        self.navigationController?.popViewControllerAnimated(true)
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        switch (indexPath.section){
        case 0: break

        case 1:
            if(indexPath.row == 1){
                if((UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0){

                    let actionSheet:UIAlertController = UIAlertController(title: NSLocalizedString("Add Alarm Label", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                    //actionSheet.view.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
                    actionSheet.addTextFieldWithConfigurationHandler({ (labelText:UITextField) -> Void in

                    })

                    let alertAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in

                    })
                    actionSheet.addAction(alertAction)

                    let alertAction1:UIAlertAction = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction) -> Void in
                        let selectedCell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
                        let labelkk = selectedCell.contentView.viewWithTag(1230)
                        let labelText:UITextField = actionSheet.textFields![0]
                        if(labelkk != nil){
                            let label:UILabel = labelkk as! UILabel
                            label.text = labelText.text
                        }else{
                            let label:UILabel = UILabel(frame: CGRectMake(0,0,80,selectedCell.contentView.frame.size.height))
                            label.tag = 1230
                            label.textAlignment = NSTextAlignment.Center
                            label.center = CGPointMake(selectedCell.contentView.frame.size.width-label.frame.size.width/2.0-15, selectedCell.contentView.frame.size.height/2.0)
                            label.text = labelText.text
                            selectedCell.contentView.addSubview(label)
                        }
                    })
                    actionSheet.addAction(alertAction1)

                    self.presentViewController(actionSheet, animated: true, completion: nil)
                }else{
                    let actionSheet:UIActionSheet = UIActionSheet(title: nil, delegate: nil, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil)
                    actionSheet.addButtonWithTitle("\(5555) steps")
                    for button:UIView in actionSheet.subviews{
                        button.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
                        button.backgroundColor = AppTheme.NEVO_SOLAR_YELLOW()
                    }
                    actionSheet.layer.backgroundColor = AppTheme.NEVO_SOLAR_YELLOW().CGColor
                    actionSheet.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
                    actionSheet.actionSheetStyle = UIActionSheetStyle.Default;
                    actionSheet.showInView(self.view)
                }
            }

        default: break 
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch (section){
        case 0:
            return 1
        case 1:
            return 2
        default: return 1;
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        if(indexPath.section == 0){
            let cellHeight:CGFloat = AddAlarmView.addAlarmTimerTableViewCell(indexPath, tableView: tableView, timer:timer).contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
            return cellHeight
        }else{
            return 45.0
        }

    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch (indexPath.section){
        case 0:
            return AddAlarmView.addAlarmTimerTableViewCell(indexPath, tableView: tableView, timer:timer)
        case 1:
            let titleArray:[String] = ["Repeat","Label"]
            let cell = AddAlarmView.systemTableViewCell(indexPath, tableView: tableView, title: titleArray[indexPath.row],delegate: self)
            let mLabel = cell.contentView.viewWithTag(1230)
            if(mLabel == nil && titleArray[indexPath.row] == "Label"){
                let label:UILabel = UILabel(frame: CGRectMake(0,0,80,cell.contentView.frame.size.height))
                label.tag = 1230
                label.textAlignment = NSTextAlignment.Center
                label.center = CGPointMake(cell.contentView.frame.size.width-label.frame.size.width/2.0-25, cell.contentView.frame.size.height/2.0)
                label.text = name
                cell.contentView.addSubview(label)
            }
            return cell
        default: return UITableViewCell();
        }
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}
