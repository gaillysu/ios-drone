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

    fileprivate let indexes:[String]
    fileprivate var cities:[String:[City]] = [:]
    fileprivate var searchController:UISearchController?
    fileprivate var searchList:[String:[(name:String, id:Int)]] = [:]
    fileprivate var searchCityController:SearchCityController = SearchCityController()
    @IBOutlet weak var cityTableView: UITableView!
    fileprivate let realm:Realm
    
    init() {
        realm = try! Realm()
            /* TODO:
        - Fix search
        - Sort cities by name in cities
        - Dismiss whenever selected a city, also in search.
        */
        for city:City in Array(realm.objects(City.self)) {
            let character:String = String(city.name[city.name.startIndex]).uppercased()
            if var list = cities[character] {
                list.append(city)
                cities[character] = list
            }else{
                cities[character] = [city]
            }
        }
        indexes = Array(cities.keys).sorted(by: { $0 < $1 })
        super.init(nibName: "AddWorldClockViewController", bundle: Bundle.main)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.navigationItem.title = "Choose a city"
        definesPresentationContext = true
        cityTableView.separatorColor = UIColor.white
        cityTableView.sectionIndexColor = UIColor.white
        
        self.addCloseButton(#selector(close))
        
        searchController = UISearchController(searchResultsController: searchCityController)
        searchCityController.mDelegate = self
        searchController?.delegate = self
        searchController?.searchResultsUpdater = self;
        searchController?.searchBar.tintColor = UIColor.white
        searchController?.searchBar.barTintColor = UIColor(patternImage: UIImage(named: "gradually")!)
        searchController?.hidesNavigationBarDuringPresentation = false;
        let searchView:UIView = UIView(frame: CGRect(x: 0,y: 0,width: UIScreen.main.bounds.size.width,height: searchController!.searchBar.frame.size.height))
        searchView.backgroundColor = UIColor(patternImage: UIImage(named: "gradually")!)
        searchView.addSubview(searchController!.searchBar)
        cityTableView.tableHeaderView = searchView
    }
    
    func close(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return indexes
    }
    
    // MARK: - UISearchControllerDelegate
    func willPresentSearchController(_ searchController: UISearchController) {
        NSLog("willPresentSearchController")
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        NSLog("didPresentSearchController")
    }
    func willDismissSearchController(_ searchController: UISearchController) {
        searchCityController.setSearchList( [:])
        NSLog("willDismissSearchController")
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        NSLog("didDismissSearchController")
        if searchController.isActive {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func presentSearchController(_ searchController: UISearchController) {
        NSLog("presentSearchController")
    }
    
    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        NSLog("updateSearchResultsForSearchController")
        if self.searchController!.searchBar.text != nil {
            let searchString:String = self.searchController!.searchBar.text!
            //过滤数据
            searchList.removeAll()
            for cityWithIndex:(String, [City]) in self.cities {
                for city:City in cityWithIndex.1 {
                    if (city.name.lowercased().range(of: searchString.lowercased()) != nil || city.country.lowercased().range(of: searchString.lowercased()) != nil) {
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
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.indexes[section]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true);
        addCity(cities[self.indexes[(indexPath as NSIndexPath).section]]![(indexPath as NSIndexPath).row])
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.indexes.count;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let unwrappedCities = self.cities[indexes[section]]{
            return unwrappedCities.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
        }
        
        let sectionName: String = self.indexes[(indexPath as NSIndexPath).section]
        
        if let citiesForSection:[City] = self.cities[sectionName]{
            cell?.textLabel?.text = "\(citiesForSection[(indexPath as NSIndexPath).row].name), \(citiesForSection[(indexPath as NSIndexPath).row].country)"
        }
        cell?.textLabel?.font = UIFont(name: "Helvetica-Light", size: 15.0)
        cell?.textLabel?.textColor = UIColor.white
        cell?.backgroundColor = UIColor.getLightBaseColor()
        return cell!;
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return self.indexes.index(of: title)!
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0;
    }
}

// MARK: DidSelectedDelegate
extension AddWorldClockViewController:DidSelectedDelegate {

    func didSelectedLocalTimeZone(_ cityId:Int) {
        let city = realm.objects(City.self).filter("id = \(cityId)")
        if(city.count != 1){
            print("Some programming error, city should always get 1 with unique ID")
            return
        }
        addCity(city[0])
    }
    
    fileprivate func addCity(_ city:City){
        let selectedCities = realm.objects(City.self).filter("selected = true")
        if selectedCities.count < 5 {
            for selectedCity:City in selectedCities {
                if city.id == selectedCity.id {
                    let alert:UIAlertController = UIAlertController(title: "Add City", message: NSLocalizedString("add_city", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                    }))
                    self.searchController?.isActive = false
                    self.present(alert, animated: true, completion:nil)
                    return
                }
            }
            try! realm.write({
                city.selected = true
            })
            AppDelegate.getAppDelegate().setWorldClock(Array(selectedCities))
            self.searchController?.isActive = false
            dismiss(animated: true, completion: nil)
        } else{
            let alert:UIAlertController = UIAlertController(title: "World Clock", message: NSLocalizedString("only_5_world_clock", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
