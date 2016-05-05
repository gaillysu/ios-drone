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
    private var citiesDict:NSDictionary!
    private var filteredCities = [String]()
    private let searchController = UISearchController(searchResultsController: nil)
    @IBOutlet weak var cityTableView: UITableView!
    
    init() {
        super.init(nibName: "AddWorldClockViewController", bundle: NSBundle.mainBundle())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        var timezone:NSDictionary = NSDictionary()
        if let path = NSBundle.mainBundle().pathForResource("localTimeZone/timezone", ofType: "plist") {
            timezone = NSDictionary(contentsOfFile: path)!
            index = timezone.allKeys as! [String]
        }
        for key in index {
            var countriesForLetter = timezone.objectForKey(key) as! [String:String]
            for country in countriesForLetter.keys {
                cities.append(country)
            }
            
        }
        
        if let dict = citiesDict {
            cities = dict.allKeys as! [String]
        }
        cities = cities.sort { $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
        index = index.sort{ $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
        definesPresentationContext = true
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.barTintColor = UIColor.getBaseColor()
        searchController.searchBar.tintColor = UIColor.whiteColor()
        searchController.searchBar.layer.borderWidth = 0.0
        definesPresentationContext = true
        cityTableView.tableHeaderView = searchController.searchBar
        cityTableView.separatorColor = UIColor.whiteColor()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredCities = cities.filter { city in
            return city.lowercaseString.containsString(searchText.lowercaseString)
        }
        
        cityTableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.index.count;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredCities.count
        }
        return cities.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        if searchController.active && searchController.searchBar.text != "" {
            cell.textLabel?.text = filteredCities[indexPath.row]
        } else {
            cell.textLabel?.text = cities[indexPath.row]
        }
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
}

extension AddWorldClockViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
