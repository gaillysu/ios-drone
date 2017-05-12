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

class NavigationController: UIViewController {
    @IBOutlet weak var navigationMapView: MKMapView!
    
    fileprivate var thePlacemark:CLPlacemark?
    fileprivate var routeDetails:MKRoute?
    
    lazy var currentPoint: MKPointAnnotation = {
        var point:MKPointAnnotation = MKPointAnnotation();
        return point
    }()
    
    fileprivate var isSetRegion:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationMapView.delegate = self
        navigationMapView.showsUserLocation = true
        navigationMapView.userTrackingMode = MKUserTrackingMode.follow
        navigationMapView.isPitchEnabled = true
        registerEventBusMessage()
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
        cleanMapViewMemory()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        applyMapViewMemoryHotFix()
    }
    
    deinit {
        deinitEventBus()
    }
}

extension NavigationController {
    func registerEventBusMessage() {
        SwiftEventBus.onMainThread(self, name: SEARCH_ACTION_CLICK) { (notification) in
            let postRoute:PostRoutes = notification.object as! PostRoutes
            self.calculateRoute(object: postRoute)
        }
    }
    
    func deinitEventBus() {
        SwiftEventBus.unregister(self, name: SEARCH_ACTION_CLICK)
    }
    
    func calculateRoute(object:PostRoutes) {
        clearRoute()
        
        self.thePlacemark = object.placemarks!;
        
        self.addAnnotation(placemark:self.thePlacemark!)
        
        self.routeDetails = object.route!;
        self.navigationMapView.add(self.routeDetails!.polyline)
        
        let point:CGPoint = CGPoint(x: self.navigationMapView.frame.size.width/2.0, y: self.navigationMapView.frame.size.height/2.0)
        let center:CLLocationCoordinate2D = navigationMapView.convert(point, toCoordinateFrom: navigationMapView)
        let regionRadius: CLLocationDistance = object.route!.distance
        let region = MKCoordinateRegionMakeWithDistance(center,regionRadius * 2.0, regionRadius * 2.0)
        self.navigationMapView.setRegion(region, animated: true)
    }
    
    func addAnnotation(placemark:CLPlacemark) {
        if let location = placemark.location {
            currentPoint.coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            
            CLGeocoder().reverseGeocodeLocationInfo(location: location) { [weak self](locationInfo, error) in
                if error == nil {
                    self?.currentPoint.title = locationInfo.name
                    self?.currentPoint.subtitle = locationInfo.locationLong
                    self?.navigationMapView.addAnnotation(self!.currentPoint)
                }
            }
        }
    }
    
    func clearRoute() {
        if let route = self.routeDetails {
            self.navigationMapView.remove(route.polyline)
            self.navigationMapView.removeAnnotation(currentPoint)
        }
    }
    
    func applyMapViewMemoryHotFix() {
        switch self.navigationMapView.mapType {
        case MKMapType.hybrid:
            self.navigationMapView.mapType = MKMapType.standard
        case MKMapType.standard:
            self.navigationMapView.mapType = MKMapType.hybrid
        default:break
            
        }
        self.navigationMapView.mapType = MKMapType.standard
    }
    
    func cleanMapViewMemory() {
        
        applyMapViewMemoryHotFix()
        
        self.navigationMapView.showsUserLocation = false
        
        navigationMapView.removeAnnotations(navigationMapView.annotations)
        
        for overlay in navigationMapView.overlays {
            navigationMapView.remove(overlay)
        }
        
        self.navigationMapView.delegate = nil
        self.navigationMapView = nil
    }
}

extension NavigationController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if !isSetRegion {
            if let location = userLocation.location {
                isSetRegion = true
                let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                let regionRadius: CLLocationDistance = 250
                let coordinateRegion = MKCoordinateRegionMakeWithDistance(center,regionRadius * 2.0, regionRadius * 2.0)
                self.navigationMapView.setRegion(coordinateRegion, animated: true)
            }
        }
        
        if let location = userLocation.location {
            CLGeocoder().reverseGeocodeLocationInfo(location: location, completion: { (locationInfo, error) in
                userLocation.title = locationInfo.name
                userLocation.subtitle = locationInfo.locationLong
            })
        }
        
        if let location = userLocation.location {
            LocationManager.manager.setCurrentLocation(locations: location)
        }
    
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let routeLineRenderer:MKPolylineRenderer = MKPolylineRenderer(polyline: routeDetails!.polyline)
        routeLineRenderer.strokeColor = UIColor.getBaseColor();
        routeLineRenderer.lineWidth = 8;
        return routeLineRenderer
    }
}
