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
import GooglePlaces

class MapTableViewController: UIViewController {
        
    @IBOutlet weak var addresTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var gripperView: UIView!
    fileprivate var tableDataSource:GMSAutocompleteTableDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        tableDataSource = GMSAutocompleteTableDataSource()
        tableDataSource?.delegate = self;
        tableDataSource?.tableCellBackgroundColor = .white
        
        addresTableView.register(UINib(nibName: "MapViewCell", bundle: nil), forCellReuseIdentifier: "MapViewCell_Identifier")
        addresTableView.separatorInset = UIEdgeInsets.zero
        
        addresTableView.delegate = tableDataSource
        addresTableView.dataSource = tableDataSource
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
}

extension MapTableViewController:UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        tableDataSource?.sourceTextHasChanged(searchBar.text)
    }
    
    func searchGeocodeAddress(object:String) {
        DRHUD.startLoading(title: nil, subtitle: nil, hide: nil)
        GoogleMapNetworkManager.manager.geocodeAddressString(address: object) { (googleModel) in
            DRHUD.hide(hideAfter: 0.1, completion: nil)
            let geocodeModelArray = googleModel == nil ? []:googleModel!
            if geocodeModelArray.count>0 {
                let geocodeModel:GoogleMapsGeocodeModel = geocodeModelArray.last!
                let routesController:RoutesController = RoutesController(nibName: "RoutesController", bundle: nil)
                routesController.geocodeModel = geocodeModel
                self.navigationController?.pushViewController(routesController, animated: true)
                
                SwiftEventBus.post(SELECTED_LOCATION_ADDRES, sender: geocodeModel)
            }
        }
    }
}

extension MapTableViewController:GMSAutocompleteTableDataSourceDelegate {
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didAutocompleteWith place: GMSPlace) {
        print("didAutocompleteWith:\(place)")
    }
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didFailAutocompleteWithError error: Error) {
        print("didFailAutocompleteWithError:\(error)")
    }
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didSelect prediction: GMSAutocompletePrediction) -> Bool {
        searchGeocodeAddress(object: prediction.attributedFullText.string)
        return false
    }
    
    func didUpdateAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
        self.addresTableView.reloadData()
    }
    
    func didRequestAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
        self.addresTableView.reloadData()
    }
}
