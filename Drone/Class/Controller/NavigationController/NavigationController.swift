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
    var currentPoint:MKPointAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationMapView.delegate = self
        navigationMapView.showsUserLocation = true
        
        registerEventBusMessage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        deinitEventBus()
    }
    
    deinit {
        deinitEventBus()
    }
}

extension NavigationController {

    func registerEventBusMessage() {
        SwiftEventBus.onMainThread(self, name: SEARCH_ACTION_CLICK) { (notification) in
            let searchPlacemark:CLPlacemark = notification.object as! CLPlacemark
            self.searchGeocodeAddress(object: searchPlacemark)
        }
    }
    
    func deinitEventBus() {
        SwiftEventBus.unregister(self, name: SEARCH_ACTION_CLICK)
    }
    
    
    func searchGeocodeAddress(object:CLPlacemark) {
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
        currentPoint = MKPointAnnotation();
        currentPoint?.coordinate = CLLocationCoordinate2DMake(placemark.location!.coordinate.latitude, placemark.location!.coordinate.longitude)
        currentPoint?.title = placemark.locality
        currentPoint?.subtitle = placemark.name
        self.navigationMapView.addAnnotation(currentPoint!)
    }
    
    func clearRoute() {
        if let route = self.routeDetails,let point = currentPoint {
            self.navigationMapView.remove(route.polyline)
            self.navigationMapView.removeAnnotation(point)
        }
    }
}

extension NavigationController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if mapView.userTrackingMode == .none {
            mapView.userTrackingMode = MKUserTrackingMode.followWithHeading
        }
        
        let center = CLLocationCoordinate2D(latitude: userLocation.location!.coordinate.latitude, longitude: userLocation.location!.coordinate.longitude)
        let regionRadius: CLLocationDistance = 250
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(center,regionRadius * 2.0, regionRadius * 2.0)
        self.navigationMapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let routeLineRenderer:MKPolylineRenderer = MKPolylineRenderer(polyline: routeDetails!.polyline)
        routeLineRenderer.strokeColor = UIColor.getBaseColor();
        routeLineRenderer.lineWidth = 8;
        return routeLineRenderer
    }
}
