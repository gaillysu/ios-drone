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
    static let instanceLocation:LocationManager = LocationManager()
    
    fileprivate var _locationManager : CLLocationManager?
    
    typealias  didUpdateLocationsCallBack=(_ locationArray :[CLLocation])->Void
    typealias  didFailWithErrorCallBack=(_ error: Error)->Void
    typealias  didChangeAuthorizationCallBack=(_ status: CLAuthorizationStatus)->Void
    
    var didUpdateLocations:didUpdateLocationsCallBack?
    var didFailWithError:didFailWithErrorCallBack?
    var didChangeAuthorization:didChangeAuthorizationCallBack?
    var gpsAuthorizationStatus:Int {
        let state:CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        switch state {
        case CLAuthorizationStatus.notDetermined:
            return Int(CLAuthorizationStatus.notDetermined.rawValue)
        case CLAuthorizationStatus.restricted:
            return Int(CLAuthorizationStatus.restricted.rawValue)
        case CLAuthorizationStatus.denied:
            return Int(CLAuthorizationStatus.denied.rawValue)
        case CLAuthorizationStatus.authorizedAlways:
            return Int(CLAuthorizationStatus.authorizedAlways.rawValue)
        case CLAuthorizationStatus.authorizedWhenInUse:
            return Int(CLAuthorizationStatus.authorizedWhenInUse.rawValue)
        default:
            return -1
        }
    }
    
    fileprivate override init() {
        super.init()
        if CLLocationManager.headingAvailable() {
            _locationManager = CLLocationManager()
            _locationManager?.delegate = self
            _locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            _locationManager?.distanceFilter = kCLLocationAccuracyKilometer
            _locationManager?.requestAlwaysAuthorization()
            _locationManager?.requestWhenInUseAuthorization()
        }else{
            let banner = Banner(title: NSLocalizedString("GPS use of infor", comment: ""), subtitle: "GPS devices do not available", image: nil, backgroundColor:UIColor.getBaseColor())
            banner.dismissesOnTap = true
            banner.show(duration: 1.2)
        }
    }
    
    func startLocation() {
        if CLLocationManager.locationServicesEnabled() {
            _locationManager?.startUpdatingLocation()
        }else{
            let banner = Banner(title: "Location services is not open", subtitle: nil , image: nil, backgroundColor:UIColor.getBaseColor())
            banner.dismissesOnTap = true
            banner.show(duration: 1.2)
        }
    }
    
    func stopLocation() {
        _locationManager?.stopUpdatingLocation()
    }
}

extension LocationManager:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        didFailWithError?(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        didUpdateLocations?(locations);
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        didChangeAuthorization?(status)
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion){
    
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion){
    
    }
}
