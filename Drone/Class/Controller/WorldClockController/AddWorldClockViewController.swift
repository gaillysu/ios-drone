//
//  AddWorldClockView.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/28.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class AddWorldClockViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource,UISearchControllerDelegate,UISearchResultsUpdating {

    private var index:[String]!
    private var cities = [String]()
    private var citiesGmtDict:NSMutableDictionary = NSMutableDictionary()
    private var citiesDict:NSMutableDictionary = NSMutableDictionary()
    private var searchController:UISearchController?
    private var searchList:NSMutableDictionary = NSMutableDictionary()
    private var searchGmtDict:NSMutableDictionary = NSMutableDictionary()
    private var searchindex:[String] = []
    private var searchResults:SearchCityController = SearchCityController()
    @IBOutlet weak var cityTableView: UITableView!
    
    init() {
        super.init(nibName: "AddWorldClockViewController", bundle: NSBundle.mainBundle())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.navigationItem.title = "Choose a city"
        //AppTheme.navigationbar(self.navigationController!)
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
        
        searchController = UISearchController(searchResultsController: searchResults)
        searchResults.mDelegate = self
        searchController?.delegate = self
        searchController?.searchResultsUpdater = self;
        searchController?.searchBar.tintColor = UIColor.whiteColor()
        searchController?.searchBar.barTintColor = UIColor(patternImage: UIImage(named: "gradually")!)
        searchController?.hidesNavigationBarDuringPresentation = false;
        let searchView:UIView = UIView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,searchController!.searchBar.frame.size.height))
        searchView.backgroundColor = UIColor(patternImage: UIImage(named: "gradually")!)
        searchView.addSubview(searchController!.searchBar)
        cityTableView.tableHeaderView = searchView
    }
    
    func close(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return index
    }
    
    // MARK: - UISearchControllerDelegate
    func willPresentSearchController(searchController: UISearchController) {
        NSLog("willPresentSearchController")
    }
    
    func didPresentSearchController(searchController: UISearchController) {
        NSLog("didPresentSearchController")
    }
    func willDismissSearchController(searchController: UISearchController) {
        searchResults.searchGmtDict = NSMutableDictionary()
        searchResults.searchList = NSMutableDictionary()
        searchResults.searchindex = []
        
        NSLog("willDismissSearchController")
    }
    
    func didDismissSearchController(searchController: UISearchController) {
        NSLog("didDismissSearchController")
        if searchController.active {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
    
    func presentSearchController(searchController: UISearchController) {
        NSLog("presentSearchController")
    }
    
    // MARK: - UISearchResultsUpdating
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        NSLog("updateSearchResultsForSearchController")
        if self.searchController!.searchBar.text != nil {
            let searchString:String = self.searchController!.searchBar.text!
            //过滤数据
            searchList.removeAllObjects()
            searchindex.removeAll()
            searchGmtDict.removeAllObjects()
            
            for (key,cityName) in self.citiesDict {
                let array:[String] = cityName as! [String]
                for (index,value) in array.enumerate() {
                    if ((value as NSString).rangeOfString(searchString).length > 0) {
                        
                        var isKey:Bool = true
                        for item in searchindex {
                            if item == key as! String {
                                isKey = false
                                break
                            }
                        }
                        
                        if isKey {
                            searchList["\(key)"] = cityName
                            searchGmtDict[value] = citiesGmtDict[value]
                            searchindex.append(key as! String)
                        }
                    }
                }
            }
            if searchList.count>0{
                searchResults.searchGmtDict = searchGmtDict
                searchResults.searchList = searchList
                searchResults.searchindex = searchindex
                searchResults.tableView.reloadData()
            }
            
        }
        
    }

    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.index[section]
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
                if displayName == worldclock.display_name {
                    let alert:UIAlertController = UIAlertController(title: "Add City", message: NSLocalizedString("add_city", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) in
                        
                    }))
                    self.searchController?.active = false
                    self.presentViewController(alert, animated: true, completion:nil)
                    return
                }else{
                    let beforeGmt:Int = Int(TimeUtil.getGmtOffSetForCity(worldclock.system_name))
                    clockNameArray.append(worldclock.city_name)
                    zoneArray.append(beforeGmt)
                }
            }
            let nameArray = displayName.componentsSeparatedByString(",")
            if nameArray.count>1 {
                clockNameArray.append(nameArray[0])
            }else{
                clockNameArray.append(displayName)
            }
            
            
            let system_name:String = (citiesGmtDict[displayName] as? String)!
            let beforeGmt:Int = TimeUtil.getGmtOffSetForCity(system_name)
            zoneArray.append(beforeGmt)
            
            AppDelegate.getAppDelegate().setWorldClock(SetWorldClockRequest(count: zoneArray.count, timeZone: zoneArray, name: clockNameArray))
            
            var cityName = displayName.componentsSeparatedByString(",")
            if cityName.count == 0 {
                cityName = [displayName]
            }
            
            let worldClock:WorldClock = WorldClock(keyDict: ["city_name":cityName[0],"system_name":citiesGmtDict[displayName]!, "display_name": displayName]);
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
    
    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.index.count;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionName:String = self.index[section]
        let citiesArrayForSection:[String] = self.citiesDict.objectForKey(sectionName) as! [String]
        return citiesArrayForSection.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        }
        let sectionName: String = self.index[indexPath.section]
        let citiesArrayForSection:[String] = self.citiesDict.objectForKey(sectionName) as! [String]
        cell?.textLabel?.text = citiesArrayForSection[indexPath.row]
        cell?.textLabel?.font = UIFont(name: "Helvetica-Light", size: 15.0)
        cell?.textLabel?.textColor = UIColor.whiteColor()
        cell?.backgroundColor = UIColor.getLightBaseColor()
        
        return cell!;
        
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return self.index.indexOf(title)!
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0;
    }
}

// MARK: DidSelectedDelegate
extension AddWorldClockViewController:DidSelectedDelegate {

    func didSelectedLocalTimeZone(ietmKey:String) {
        let displayName:String = ietmKey
        var array:NSMutableArray = NSMutableArray() {
            didSet {
                let timeZone: String = NSTimeZone.localTimeZone().name
                let timeZoneArray:[String] = timeZone.characters.split{$0 == "/"}.map(String.init)
                let wordClock:WorldClock = WorldClock(keyDict: ["system_name":timeZone,"city_name":timeZoneArray[1],"display_name":"\(timeZoneArray[1]), \(timeZoneArray[0])"])
                array.insertObject(wordClock, atIndex: 0)
            }
        }
        array = NSMutableArray(array: WorldClock.getAll())
        
        if array.count < 5 {
            var clockNameArray:[String] = []
            var zoneArray:[Int] = []
            
            for (index,value) in array.enumerate() {
                let worldclock:WorldClock = value as! WorldClock
                if displayName == worldclock.display_name {
                    let alert:UIAlertController = UIAlertController(title: "Add City", message: NSLocalizedString("add_city", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) in
                        
                    }))
                    self.searchController?.active = false
                    self.presentViewController(alert, animated: true, completion:nil)
                    return
                }else{
                    let beforeGmt:Int = Int(TimeUtil.getGmtOffSetForCity(worldclock.system_name))
                    
                    let timeZone: String = NSTimeZone.localTimeZone().name
                    let timeZoneArray:[String] = timeZone.characters.split{$0 == "/"}.map(String.init)
                    
                    if timeZoneArray[1] !=  worldclock.city_name{
                        clockNameArray.append(worldclock.city_name)
                        zoneArray.append(beforeGmt)
                    }
                }
            }
            clockNameArray.append(displayName)
            
            let system_name:String = (searchGmtDict[displayName] as? String)!
            let beforeGmt:Int = TimeUtil.getGmtOffSetForCity(system_name)
            zoneArray.append(beforeGmt)
            
            AppDelegate.getAppDelegate().setWorldClock(SetWorldClockRequest(count: zoneArray.count, timeZone: zoneArray, name: clockNameArray))
            
            var cityName = displayName.componentsSeparatedByString(",")
            if cityName.count == 0 {
                cityName = [displayName]
            }
            
            let worldClock:WorldClock = WorldClock(keyDict: ["city_name":cityName[0],"system_name":searchGmtDict[displayName]!, "display_name": displayName]);
            worldClock.add { (id, completion) in
                if(Bool(completion!)) {
                    print("word clock added to db!")
                }else{
                    print("word clock add db fail!")
                }
                self.searchController?.active = false
            }
        }else{
            let alert:UIAlertController = UIAlertController(title: "World Clock", message: NSLocalizedString("only_5_world_clock", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) in
                
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}