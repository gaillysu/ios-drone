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
                citiesGmtDict[city]  = countriesForLetter[city]
                
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
        let cityName:String = citiesArrayForSection[indexPath.row]
        let gmtOffset = citiesGmtDict[cityName]
        let worldClock:WorldClock = WorldClock(keyDict: ["gmt_offset":gmtOffset!,"city_name":cityName])
        worldClock.add { (id, completion) in
            if(Bool(completion!)) {
                print("word clock added to db!")
            }else{
                print("word clock add db fail!")
            }
        }

        let gmt:Int = (gmtOffset as! NSString).integerValue
        let zone:NSTimeZone = NSTimeZone(forSecondsFromGMT: gmt)
        let array:NSArray = WorldClock.getAll()
        var clockArray:[SetWorldClockRequest] = []
        for (index,value) in array.enumerate() {
            let wordclock:WorldClock = value as! WorldClock
            let beforeGmt:Int = (wordclock.gmt_offset as NSString).integerValue
            let beforeTimeZone:NSTimeZone = NSTimeZone(forSecondsFromGMT: beforeGmt)
            clockArray.append(SetWorldClockRequest(count: index, timeZone: beforeTimeZone, name: wordclock.city_name))
        }
        AppDelegate.getAppDelegate().setWorldClock(clockArray+[SetWorldClockRequest(count: clockArray.count, timeZone: zone, name: cityName)])
        dismissViewControllerAnimated(true, completion: nil)
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
