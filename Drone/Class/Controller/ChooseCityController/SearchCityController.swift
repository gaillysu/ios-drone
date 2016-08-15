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
    private var searchList:[String:[(name:String, id:Int)]] = [:]
    private var index:[String] = []
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
        searchList = [:]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setSearchList(searchList:[String:[(name:String, id:Int)]]){
        self.searchList = searchList
        self.index = Array(searchList.keys)
        self.index = index.sort({ (s1:String, s2:String) -> Bool in
            return s1 < s2
        })
    }
    
    // MARK: - Table view delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        if searchList.count == 0{
            return
        }
        if let cities:[(name:String, id:Int)] = searchList[index[indexPath.section]]{
            mDelegate?.didSelectedLocalTimeZone(cities[indexPath.row].id)
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return index.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchList[index[section]]!.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("AddClockIdentifier")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "AddClockIdentifier")
        }
        if let cities:[(name:String, id:Int)] = searchList[index[indexPath.section]]{
            cell?.textLabel?.text = cities[indexPath.row].name
        }
        cell?.textLabel?.font = UIFont(name: "Helvetica-Light", size: 15.0)
        return cell!
    }
}
