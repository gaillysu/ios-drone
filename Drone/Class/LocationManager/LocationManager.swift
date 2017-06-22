//
//  LocationManager.swift
//  Nevo
//
//  Created by Cloud on 2016/10/25.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import CoreLocation
import BRYXBanner

class LocationManager: NSObject {
    static let manager:LocationManager = LocationManager()
    
    var currentLocation:CLLocation? {
        get{
            return location
        }
    }
    
    fileprivate var location:CLLocation?
    fileprivate var _locationManager : CLLocationManager?
    
    typealias  didUpdateLocationsCallBack=(_ locationArray :[CLLocation])->Void
    typealias  didFailWithErrorCallBack=(_ error: Error)->Void
    typealias  didChangeAuthorizationCallBack=(_ status: CLAuthorizationStatus)->Void
    
    var didUpdateLocations:didUpdateLocationsCallBack?
    var didFailWithError:didFailWithErrorCallBack?
    var didChangeAuthorization:didChangeAuthorizationCallBack?
    var gpsAuthorizationStatus:Bool {
        let state:CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        switch state {
        case CLAuthorizationStatus.notDetermined:
            return false
        case CLAuthorizationStatus.restricted:
            return false
        case CLAuthorizationStatus.denied:
            return false
        case CLAuthorizationStatus.authorizedAlways:
            return true
        case CLAuthorizationStatus.authorizedWhenInUse:
            return true
        }
    }
    
    var locationEnabled:Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    
    
    fileprivate override init() {
        super.init()
        if CLLocationManager.headingAvailable() && locationEnabled {
            _locationManager = CLLocationManager()
            _locationManager?.delegate = self
            _locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            _locationManager?.distanceFilter = kCLLocationAccuracyKilometer
            _locationManager?.requestWhenInUseAuthorization()
        }else{
            let banner = Banner(title: NSLocalizedString("GPS use of infor", comment: ""), subtitle: "GPS devices do not available", image: nil, backgroundColor:UIColor.getBaseColor())
            banner.dismissesOnTap = true
            banner.show(duration: 1.2)
        }
    }
    
    func startLocation() {
        if locationEnabled {
            _locationManager?.startUpdatingLocation()
        }else{
            let banner = Banner(title: "Location services is not open", subtitle: nil , image: nil, backgroundColor:UIColor.getBaseColor())
            banner.dismissesOnTap = true
            banner.show(duration: 1.2)
        }
    }
    
    func stopLocation() {
        if locationEnabled {
            _locationManager?.stopUpdatingLocation()
        }
    }
}

extension LocationManager:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        didFailWithError?(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        didUpdateLocations?(locations);
        if currentLocation == nil {
            location = locations.last
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        didChangeAuthorization?(status)
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion){
    
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion){
    
    }
}
