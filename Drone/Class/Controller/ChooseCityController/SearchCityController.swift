//
//  ChooseCityController.swift
//  Drone
//
//  Created by leiyuncun on 16/4/27.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit

class SearchCityController: UITableViewController {
    var mDelegate:DidSelectedDelegate?
    var searchList:NSMutableDictionary = NSMutableDictionary()
    var searchindex:[String] = []
    var searchGmtDict:NSMutableDictionary = NSMutableDictionary()
    
    init() {
        super.init(nibName: "SearchCityController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        searchList = NSMutableDictionary()
        searchindex = []
        searchGmtDict = NSMutableDictionary()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        if self.searchindex.count==0 || searchList.count==0 || searchGmtDict.count==0 {
            return
        }
        let sectionName: String = self.searchGmtDict.allKeys[indexPath.row] as! String
        mDelegate?.didSelectedLocalTimeZone(sectionName)
        //self.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return searchindex.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchGmtDict.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("AddClockIdentifier")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "AddClockIdentifier")
        }
        cell?.textLabel?.text = searchGmtDict.allKeys[indexPath.row] as? String
        cell?.textLabel?.font = UIFont(name: "Helvetica-Light", size: 15.0)
        return cell!
    }

}
