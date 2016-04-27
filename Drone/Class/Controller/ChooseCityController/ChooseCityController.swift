//
//  ChooseCityController.swift
//  Drone
//
//  Created by leiyuncun on 16/4/27.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit

class ChooseCityController: UITableViewController,UISearchControllerDelegate,UISearchResultsUpdating {
    var mDelegate:didSelectedDelegate?
    private var searchController:UISearchController?
    private var clockArray:[NSDictionary] = AppTheme.loadResourcesFile("localTimeZone")
    private var searchList:[NSDictionary] = []

    init() {
        super.init(nibName: "ChooseCityController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "gradually"), forBarMetrics: UIBarMetrics.Default)
        searchController = UISearchController(searchResultsController: nil)
        searchController?.delegate = self
        searchController?.searchResultsUpdater = self;
        searchController?.searchBar.tintColor = UIColor.whiteColor()
        searchController?.searchBar.barTintColor = UIColor(patternImage: UIImage(named: "gradually")!)
         searchController?.hidesNavigationBarDuringPresentation = false;
        self.tableView.tableHeaderView = searchController?.searchBar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - UISearchControllerDelegate
    func willPresentSearchController(searchController: UISearchController) {
        NSLog("willPresentSearchController")
    }

    func didPresentSearchController(searchController: UISearchController) {
        NSLog("didPresentSearchController")
    }
    func willDismissSearchController(searchController: UISearchController) {
        NSLog("willDismissSearchController")
    }

    func didDismissSearchController(searchController: UISearchController) {
        NSLog("didDismissSearchController")
    }

    func presentSearchController(searchController: UISearchController) {
        NSLog("presentSearchController")
    }

    // MARK: - UISearchResultsUpdating
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        NSLog("updateSearchResultsForSearchController")
        let searchString:String = self.searchController!.searchBar.text!
        if (self.searchList.count != 0) {
            self.searchList.removeAll()
        }

        let preicate:NSPredicate = NSPredicate(format:"name LIKE[cd] %@", searchString)
        let pre:NSPredicate = preicate.predicateWithSubstitutionVariables([searchString:searchString])
        //过滤数据
        self.searchList = (self.clockArray as NSArray).filteredArrayUsingPredicate(pre) as! [NSDictionary];
        self.tableView.reloadData()
    }

    // MARK: - Table view delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        mDelegate?.didSelectedLocalTimeZone(clockArray[indexPath.row])
        self.navigationController?.popViewControllerAnimated(true)
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.searchController!.active) {
            return searchList.count
        }else{
            return clockArray.count
        }
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("AddClockIdentifier")
        if(cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "AddClockIdentifier")
        }
        let cellDict:NSDictionary = clockArray[indexPath.row]
        cellDict.enumerateKeysAndObjectsUsingBlock({ (key, obj, stop) -> Void in
            cell?.textLabel?.text = key as? String
            cell?.detailTextLabel?.text = obj as? String
        })

        return cell!
    }

}
