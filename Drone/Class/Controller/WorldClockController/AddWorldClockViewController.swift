//
//  AddWorldClockView.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/28.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import RealmSwift
import UIKit

class AddWorldClockViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource,UISearchControllerDelegate,UISearchResultsUpdating {

    private let indexes:[String]
    private var cities:[String:[City]] = [:]
    private var searchController:UISearchController?
    private var searchList:[String:[(name:String, id:Int)]] = [:]
    private var searchCityController:SearchCityController = SearchCityController()
    @IBOutlet weak var cityTableView: UITableView!
    private let realm:Realm
    
    init() {
        realm = try! Realm()
            /* TODO:
        - Fix search
        - Sort cities by name in cities
        - Dismiss whenever selected a city, also in search.
        */
        for city:City in Array(realm.objects(City)) {
            let character:String = String(city.name[city.name.startIndex]).uppercaseString
            if var list = cities[character] {
                list.append(city)
                cities[character] = list
            }else{
                cities[character] = [city]
            }
        }
        indexes = Array(cities.keys).sort({ $0 < $1 })
        super.init(nibName: "AddWorldClockViewController", bundle: NSBundle.mainBundle())
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.navigationItem.title = "Choose a city"
        definesPresentationContext = true
        cityTableView.separatorColor = UIColor.whiteColor()
        cityTableView.sectionIndexColor = UIColor.whiteColor()
        
        let button: UIButton = UIButton(type: UIButtonType.Custom)
        button.setImage(UIImage(named: "closebutton"), forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(close), forControlEvents: UIControlEvents.TouchUpInside)
        button.frame = CGRectMake(0, 0, 30, 30)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
        
        searchController = UISearchController(searchResultsController: searchCityController)
        searchCityController.mDelegate = self
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
        return indexes
    }
    
    // MARK: - UISearchControllerDelegate
    func willPresentSearchController(searchController: UISearchController) {
        NSLog("willPresentSearchController")
    }
    
    func didPresentSearchController(searchController: UISearchController) {
        NSLog("didPresentSearchController")
    }
    func willDismissSearchController(searchController: UISearchController) {
        searchCityController.setSearchList( [:])
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
            searchList.removeAll()
            for cityWithIndex:(String, [City]) in self.cities {
                for city:City in cityWithIndex.1 {
                    if (city.name.lowercaseString.rangeOfString(searchString.lowercaseString) != nil || city.country.lowercaseString.rangeOfString(searchString.lowercaseString) != nil) {
                        if var array = searchList[cityWithIndex.0]{
                            array.append(("\(city.name), \(city.country)",city.id))
                            searchList[cityWithIndex.0] = array
                        }else{
                            searchList[cityWithIndex.0] = [("\(city.name), \(city.country)",city.id)]
                        }
                    }
                }
            }
            if searchList.count>0{
                searchCityController.setSearchList(searchList)
                searchCityController.tableView.reloadData()
            }else{
                searchCityController.setSearchList([:])
                searchCityController.tableView.reloadData()
            }
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.indexes[section]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        addCity(cities[self.indexes[indexPath.section]]![indexPath.row])
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.indexes.count;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let unwrappedCities = self.cities[indexes[section]]{
            return unwrappedCities.count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        }
        
        let sectionName: String = self.indexes[indexPath.section]
        
        if let citiesForSection:[City] = self.cities[sectionName]{
            cell?.textLabel?.text = "\(citiesForSection[indexPath.row].name), \(citiesForSection[indexPath.row].country)"
        }
        cell?.textLabel?.font = UIFont(name: "Helvetica-Light", size: 15.0)
        cell?.textLabel?.textColor = UIColor.whiteColor()
        cell?.backgroundColor = UIColor.getLightBaseColor()
        return cell!;
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return self.indexes.indexOf(title)!
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0;
    }
}

// MARK: DidSelectedDelegate
extension AddWorldClockViewController:DidSelectedDelegate {

    func didSelectedLocalTimeZone(cityId:Int) {
        let city = realm.objects(City).filter("id = \(cityId)")
        if(city.count != 1){
            print("Some programming error, city should always get 1 with unique ID")
            return
        }
        addCity(city[0])
    }
    
    private func addCity(city:City){
        let selectedCities = realm.objects(City).filter("selected = true")
        if selectedCities.count < 5 {
            for selectedCity:City in selectedCities {
                if city.id == selectedCity.id {
                    let alert:UIAlertController = UIAlertController(title: "Add City", message: NSLocalizedString("add_city", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) in
                    }))
                    self.searchController?.active = false
                    self.presentViewController(alert, animated: true, completion:nil)
                    return
                }
            }
            try! realm.write({
                city.selected = true
            })
            AppDelegate.getAppDelegate().setWorldClock(Array(selectedCities))
            self.searchController?.active = false
            dismissViewControllerAnimated(true, completion: nil)
        } else{
            let alert:UIAlertController = UIAlertController(title: "World Clock", message: NSLocalizedString("only_5_world_clock", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) in
                
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}