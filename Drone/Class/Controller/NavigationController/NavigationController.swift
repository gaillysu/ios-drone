//
//  NavigationController.swift
//  Drone
//
//  Created by Cloud on 2017/5/5.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SwiftEventBus
import GoogleMaps

class NavigationController: UIViewController {
    @IBOutlet weak var navigationMapView: GMSMapView!
    
    fileprivate let myLocation:String = "MyLocation_Identifier"
    fileprivate var firstLocationUpdate:Bool = false
    fileprivate var thePlacemark:CLPlacemark?
    fileprivate var routeDetails:MKRoute?
    
    fileprivate var isSetRegion:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        registerEventBusMessage()

        configMapView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !LocationManager.manager.gpsAuthorizationStatus && !LocationManager.manager.locationEnabled {
            let alertControl:UIAlertController = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("turn_on_GPS_message", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            let alertAction:UIAlertAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: UIAlertActionStyle.cancel, handler: { (action) in
                self.dismiss(animated: true, completion: nil)
            })
            alertControl.addAction(alertAction)
            self.present(alertControl, animated: true, completion: nil)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        deinitEventBus()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        deinitEventBus()
        navigationMapView.removeObserver(self, forKeyPath: myLocation)
    }
}

extension NavigationController {
    func registerEventBusMessage() {
        SwiftEventBus.onMainThread(self, name: SEARCH_ACTION_CLICK) { (notification) in
            let postRoute:PostRoutes = notification.object as! PostRoutes
            postRoute.rectangle?.map = self.navigationMapView
        }
    }
    
    func deinitEventBus() {
        SwiftEventBus.unregister(self, name: SEARCH_ACTION_CLICK)
    }
    
    func configMapView() {
        navigationMapView.delegate = self
        navigationMapView.settings.compassButton = true;
        navigationMapView.settings.myLocationButton = true;
        navigationMapView.isMyLocationEnabled = true
        //geocoding api, directions api
        
        let Location = LocationManager.manager.currentLocation ?? CLLocation(latitude: 0, longitude: 0)
        let locationLatitude:Double = Location.coordinate.latitude
        let locationLongitude:Double = Location.coordinate.longitude
        let camera:GMSCameraPosition = GMSCameraPosition.camera(withLatitude: locationLatitude, longitude: locationLongitude, zoom: 14)
        navigationMapView.camera = camera
        navigationMapView.addObserver(self, forKeyPath: myLocation, options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let key = keyPath,key == myLocation {
            if !firstLocationUpdate {
                firstLocationUpdate = true;
                if let changeObject = change {
                    let location:CLLocation = changeObject[NSKeyValueChangeKey.newKey] as! CLLocation
                    let camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 14)
                    navigationMapView.camera = camera
                }
            }
        }
    }
}

// MARK: - GMSMapViewDelegate
extension NavigationController: GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
    
    }
}
