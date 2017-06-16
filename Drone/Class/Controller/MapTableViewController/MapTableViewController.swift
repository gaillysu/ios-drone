//
//  MapTableViewController.swift
//  Drone
//
//  Created by Cloud on 2017/5/5.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit
import SwiftEventBus
import MapKit
import CoreLocation
import Pulley

class MapTableViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
        
    @IBOutlet weak var addresTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var gripperView: UIView!
    fileprivate var pointArray:[GoogleMapsGeocodeModel] = []
    
    
    
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
        return 60
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pointArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MapViewCell = tableView.dequeueReusableCell(withIdentifier: "MapViewCell_Identifier", for: indexPath) as! MapViewCell
        let geocodeModel:GoogleMapsGeocodeModel = pointArray[indexPath.row]
        cell.googleModel = geocodeModel

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let geocodeModel:GoogleMapsGeocodeModel = pointArray[indexPath.row]
        let routesController:RoutesController = RoutesController(nibName: "RoutesController", bundle: nil)
        routesController.geocodeModel = geocodeModel
        self.navigationController?.pushViewController(routesController, animated: true)
    }
}

extension MapTableViewController:UISearchBarDelegate {    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchGeocodeAddress(object: searchBar.text!)
        
        searchBar.resignFirstResponder()
    }
    
    func searchGeocodeAddress(object:String) {
        DRHUD.startLoading(title: nil, subtitle: nil, hide: nil)
        GoogleMapNetworkManager.manager.geocodeAddressString(address: object) { (googleModel) in
            DRHUD.hide(hideAfter: 0.1, completion: nil)
            self.pointArray.removeAll()
            googleModel?.forEach({ (theGoogleModel) in
                self.pointArray.append(theGoogleModel)
            })
            
            self.addresTableView.reloadData()
        }
    }
}
