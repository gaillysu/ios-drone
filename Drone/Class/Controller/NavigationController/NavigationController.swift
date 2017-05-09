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
    var thePlacemark:CLPlacemark?
    var routeDetails:MKRoute?
    @IBOutlet weak var zoomOut: UIButton!
    @IBOutlet weak var zoomAdd: UIButton!
    
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
        
        registerEventBusMessage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        deinitEventBus()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        applyMapViewMemoryHotFix()
    }
    
    @IBAction func zoomAction(_ sender: Any) {
        if zoomOut.isEqual(sender) {
            
        }
        
        if zoomAdd.isEqual(sender) {
            
        }
    }
    
    deinit {
        deinitEventBus()
    }
}

extension NavigationController {

    func registerEventBusMessage() {
        SwiftEventBus.onMainThread(self, name: SEARCH_ACTION_CLICK) { (notification) in
            let searchPlacemark:CLPlacemark = notification.object as! CLPlacemark
            self.selectedSearchGeocodeAddress(object: searchPlacemark)
        }
    }
    
    func deinitEventBus() {
        SwiftEventBus.unregister(self, name: SEARCH_ACTION_CLICK)
    }
    
    
    func selectedSearchGeocodeAddress(object:CLPlacemark) {
        clearRoute()
        
        self.thePlacemark = object;
        
        let center = CLLocationCoordinate2D(latitude: self.thePlacemark!.location!.coordinate.latitude, longitude: self.thePlacemark!.location!.coordinate.longitude)
        let regionRadius: CLLocationDistance = 100
        let region = MKCoordinateRegionMakeWithDistance(center,regionRadius * 2.0, regionRadius * 2.0)

        self.navigationMapView.setRegion(region, animated: true)
        self.addAnnotation(placemark:self.thePlacemark!)
        
        calculateRoute()
    }
    
    func calculateRoute() {
        let placemark:MKPlacemark = MKPlacemark(placemark: thePlacemark!)
        placemark.calculateRoute { (route, error) in
            if error == nil {
                self.routeDetails = route;
                self.navigationMapView.add(self.routeDetails!.polyline)
            }
        }
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
                
                CLGeocoder().reverseGeocodeLocationInfo(location: location, completion: { (locationInfo, error) in
                    userLocation.title = locationInfo.name
                    userLocation.subtitle = locationInfo.locationLong
                })
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let routeLineRenderer:MKPolylineRenderer = MKPolylineRenderer(polyline: routeDetails!.polyline)
        routeLineRenderer.strokeColor = UIColor.getBaseColor();
        routeLineRenderer.lineWidth = 8;
        return routeLineRenderer
    }
}
