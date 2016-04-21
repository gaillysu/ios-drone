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

class WorldClockController: BaseViewController {

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

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "gradually"), forBarMetrics: UIBarMetrics.Default)
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let rightAddButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: #selector(WorldClockController.controllManager(_:)))
        self.navigationItem.rightBarButtonItem = rightAddButton

        worldClockTableview.allowsSelectionDuringEditing = true;
    }

    func controllManager(sender:UIBarButtonItem) {

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
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return WorldClockCell.getWorldClockCell(tableView, indexPath: indexPath, clock:wordclockArray[indexPath.row])
    }


}
