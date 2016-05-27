//
//  ChooseCityController.swift
//  Drone
//
//  Created by leiyuncun on 16/4/27.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit

class SearchCityController: UITableViewController {
    var mDelegate:didSelectedDelegate?
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
        let sectionName: String = self.searchindex[indexPath.section]
        let citiesArrayForSection:[String] = self.searchList.objectForKey(sectionName) as! [String]
        let displayName:String = citiesArrayForSection[indexPath.row]
        let array:NSArray = WorldClock.getAll()
        
        if array.count < 5 {
            var clockNameArray:[String] = []
            var zoneArray:[Int] = []
            
            for (index,value) in array.enumerate() {
                let worldclock:WorldClock = value as! WorldClock
                let beforeGmt:Int = Int(TimeUtil.getGmtOffSetForCity(worldclock.system_name))
                clockNameArray.append(worldclock.city_name)
                zoneArray.append(beforeGmt)
            }
            clockNameArray.append(displayName)
            
            let system_name:String = (searchGmtDict[displayName] as? String)!
            let beforeGmt:Int = TimeUtil.getGmtOffSetForCity(system_name)
            zoneArray.append(beforeGmt)
            
            AppDelegate.getAppDelegate().setWorldClock(SetWorldClockRequest(count: zoneArray.count, timeZone: zoneArray, name: clockNameArray))
            
            var cityName = displayName
            
            let range: Range<String.Index> = cityName.rangeOfString(",")!
            var index: Int = cityName.startIndex.distanceTo(range.startIndex)
            index = index - 1
            let newRange = cityName.endIndex.advancedBy((index * -1))..<cityName.endIndex
            cityName.removeRange(newRange)
            let worldClock:WorldClock = WorldClock(keyDict: ["city_name":cityName,"system_name":searchGmtDict[displayName]!, "display_name": displayName]);
            worldClock.add { (id, completion) in
                if(Bool(completion!)) {
                    print("word clock added to db!")
                }else{
                    print("word clock add db fail!")
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }else{
            let alert:UIAlertController = UIAlertController(title: "World Clock", message: NSLocalizedString("only_5_world_clock", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) in
                
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return searchindex.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionName:String = self.searchindex[section]
        let citiesArrayForSection:[String] = self.searchList.objectForKey(sectionName) as! [String]
        return citiesArrayForSection.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("AddClockIdentifier")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "AddClockIdentifier")
        }
        let sectionName: String = self.searchindex[indexPath.section]
        let citiesArrayForSection:[String] = self.searchList.objectForKey(sectionName) as! [String]
        cell?.textLabel?.text = citiesArrayForSection[indexPath.row]
        cell?.textLabel?.font = UIFont(name: "Helvetica-Light", size: 15.0)
        cell?.textLabel?.textColor = UIColor.whiteColor()
        cell?.backgroundColor = UIColor.getLightBaseColor()
        return cell!
    }

}
