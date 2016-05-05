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

class WorldClockViewController: BaseViewController {

    @IBOutlet weak var worldClockTableview: UITableView!
    var wordclockArray:[NSDictionary] = []

    init() {
        super.init(nibName: "WorldClockViewController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "World Clock"
        // TODO set headerview: WorldClockHeader.swift
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()

        worldClockTableview.backgroundColor = UIColor(rgba: "#E4C590")
        worldClockTableview.allowsSelectionDuringEditing = true;
        worldClockTableview.tableHeaderView = WorldClockHeader.getWorldClockHeader(CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.width-60))
        
        let button: UIButton = UIButton(type: UIButtonType.Custom)
        button.setImage(UIImage(named: "addbutton"), forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(add), forControlEvents: UIControlEvents.TouchUpInside)
        button.frame = CGRectMake(0, 0, 30, 30)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
        let dict:NSMutableDictionary = NSMutableDictionary();
        dict["textLabel"] = "Yo";
        dict["detailTextLabel"] = "Yo";
    }
    
    func add(){
        self.navigationController?.pushViewController(AddWorldClockViewController(), animated: true)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordclockArray.count
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
        } else if editingStyle == .Insert {
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return WorldClockCell.getWorldClockCell(tableView, indexPath: indexPath, clock:wordclockArray[indexPath.row])
    }


}
