//
//  WorldClockController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/25.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

protocol didSelectedDelegate:NSObjectProtocol {
    func didSelectedLocalTimeZone(ietm:NSDictionary)
}

class WorldClockController: UIViewController,didSelectedDelegate {

    @IBOutlet weak var worldClockTableview: UITableView!
    var wordclockArray:[NSDictionary] = []

    init() {
        super.init(nibName: "WorldClockController", bundle: NSBundle.mainBundle())

    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "World Clock"
        let rightBar:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: Selector("buttonManager:"))
        self.navigationItem.rightBarButtonItem = rightBar
        // Do any additional setup after loading the view.

        if((AppTheme.LoadKeyedArchiverName("LocalTimeZone") as! [AnyObject]).count>0) {
             wordclockArray = (AppTheme.LoadKeyedArchiverName("LocalTimeZone") as! [AnyObject])[0] as! [NSDictionary]
        }

    }

    func buttonManager(sender:AnyObject) {
        let addClock:AddWorldClockController = AddWorldClockController()
        addClock.mDelegate = self
        self.navigationController?.pushViewController(addClock, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordclockArray.count
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            wordclockArray.removeAtIndex(indexPath.row)
            KeyedArchiver()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return WorldClockCell.getWorldClockCell(tableView, indexPath: indexPath, clock:wordclockArray[indexPath.row])
    }

    // MARK: - didSelectedDelegate
    func didSelectedLocalTimeZone(ietm:NSDictionary) {
        wordclockArray.append(ietm)
        let indexPath: NSIndexPath = NSIndexPath(forRow: wordclockArray.count-1, inSection: 0)
        worldClockTableview.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        KeyedArchiver()
    }

    private func KeyedArchiver(){
        AppTheme.KeyedArchiverName("LocalTimeZone", andObject: wordclockArray)
        var clockArray:[SetWorldClockRequest] = []
        for(var index:Int = 0;index<wordclockArray.count;index++) {
            let clockDict:NSDictionary = wordclockArray[index]
            clockDict.enumerateKeysAndObjectsUsingBlock({ (key, obj, stop) -> Void in
                let timerZone:NSTimeZone = NSTimeZone(name: "\(key)")!
                clockArray.append(SetWorldClockRequest(count: index+1, timerZone: timerZone, name: "\(key)"))
            })
        }
        AppDelegate.getAppDelegate().setWorldClock(clockArray)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
