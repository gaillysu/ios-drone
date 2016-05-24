//
//  AddWorldClockView.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/28.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class AddWorldClockViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    private var index:[String]!
    private var cities = [String]()
    private var citiesGmtDict:NSMutableDictionary! = NSMutableDictionary()
    private var citiesDict:NSMutableDictionary! = NSMutableDictionary()
    @IBOutlet weak var cityTableView: UITableView!
    
    init() {
        super.init(nibName: "AddWorldClockViewController", bundle: NSBundle.mainBundle())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.navigationItem.title = "Choose a city"
        var timezone:NSDictionary = NSDictionary()
        if let path = NSBundle.mainBundle().pathForResource("localTimeZone/timezone", ofType: "plist") {
            timezone = NSDictionary(contentsOfFile: path)!
            index = timezone.allKeys as! [String]
        }
        for key in index {
            let countriesForLetter = timezone.objectForKey(key) as! [String:String]
            var countryPerLetter = [String]()
            for city in countriesForLetter.keys {
                countryPerLetter.append(city)
                cities.append(city)
                citiesDict[key] = countryPerLetter.sort { $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
                citiesGmtDict[city] = countriesForLetter[city]
                
            }
        }
        cities = cities.sort { $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
        index = index.sort{ $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
        definesPresentationContext = true
        cityTableView.separatorColor = UIColor.whiteColor()
        cityTableView.sectionIndexColor = UIColor.whiteColor()
        
        let button: UIButton = UIButton(type: UIButtonType.Custom)
        button.setImage(UIImage(named: "closebutton"), forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(close), forControlEvents: UIControlEvents.TouchUpInside)
        button.frame = CGRectMake(0, 0, 30, 30)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    func close(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.index.count;
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.index[section]
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionName:String = self.index[section]
        let citiesArrayForSection:[String] = self.citiesDict.objectForKey(sectionName) as! [String]
        return citiesArrayForSection.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        let sectionName: String = self.index[indexPath.section]
        let citiesArrayForSection:[String] = self.citiesDict.objectForKey(sectionName) as! [String]
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
            
            let system_name:String = (citiesGmtDict[displayName] as? String)!
            let beforeGmt:Int = TimeUtil.getGmtOffSetForCity(system_name)
            zoneArray.append(beforeGmt)
            
            AppDelegate.getAppDelegate().setWorldClock(SetWorldClockRequest(count: zoneArray.count, timeZone: zoneArray, name: clockNameArray))
            
            var cityName = displayName
        
            let range: Range<String.Index> = cityName.rangeOfString(",")!
            var index: Int = cityName.startIndex.distanceTo(range.startIndex)
            index = index - 1
            let newRange = cityName.endIndex.advancedBy((index * -1))..<cityName.endIndex
            cityName.removeRange(newRange)
            let worldClock:WorldClock = WorldClock(keyDict: ["city_name":cityName,"system_name":citiesGmtDict[displayName]!, "display_name": displayName]);
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        let sectionName: String = self.index[indexPath.section]
        let citiesArrayForSection:[String] = self.citiesDict.objectForKey(sectionName) as! [String]
        cell.textLabel?.text = citiesArrayForSection[indexPath.row]
        cell.textLabel?.font = UIFont(name: "Helvetica-Light", size: 15.0)
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.backgroundColor = UIColor.getLightBaseColor()
        
        return cell;
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return index
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return self.index.indexOf(title)!
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0;
    }
}
