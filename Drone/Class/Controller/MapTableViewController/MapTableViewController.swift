//
//  MapTableViewController.swift
//  Drone
//
//  Created by Cloud on 2017/5/5.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit
import SnapKit
import SwiftEventBus
import MapKit
import CoreLocation

class MapTableViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
        
    @IBOutlet weak var addresTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var gripperView: UIView!
    var pointArray:[CLPlacemark] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addresTableView.register(UINib(nibName: "MapViewCell", bundle: nil), forCellReuseIdentifier: "MapViewCell_Identifier")
        addresTableView.separatorInset = UIEdgeInsets.zero
        addresTableView.tableFooterView = UIView()
        
        searchBar.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pointArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MapViewCell = tableView.dequeueReusableCell(withIdentifier: "MapViewCell_Identifier", for: indexPath) as! MapViewCell
        let placemarks:CLPlacemark = pointArray[indexPath.row]
        cell.placemarks = placemarks

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let placemarks:CLPlacemark = pointArray[indexPath.row]
        SwiftEventBus.post(SEARCH_ACTION_CLICK, sender: placemarks)
    }
}

extension MapTableViewController:UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchGeocodeAddress(object: searchBar.text!)
        
        searchBar.resignFirstResponder()
    }
    
    func searchGeocodeAddress(object:String) {
        let geocoder:CLGeocoder = CLGeocoder()
        geocoder.geocodeAddressString(object) { (placemarks, error) in
            if error != nil {
                NSLog("%@", error!.localizedDescription);
            } else {
                if let mPlacemarks = placemarks {
                    self.pointArray.removeAll()
                    
                    for thePlacemark in mPlacemarks{
                        self.pointArray.append(thePlacemark)
                    }
                    
                    self.addresTableView.reloadData()
                }
                
            }
        }
    }
}
