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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            let searchText:String = notification.object as! String
            self.searchGeocodeAddress(object: searchText)
        }
    }
    
    func deinitEventBus() {
        SwiftEventBus.unregister(self, name: SEARCH_ACTION_CLICK)
    }
    
    
    func searchGeocodeAddress(object:String) {
        let geocoder:CLGeocoder = CLGeocoder()
        geocoder.geocodeAddressString(object) { (placemarks, error) in
            if error != nil {
                NSLog("%@", error!.localizedDescription);
            } else {
                self.thePlacemark = placemarks?.last;
                let spanX:Double = 1.00725;
                let spanY:Double = 1.00725;
                var region:MKCoordinateRegion = MKCoordinateRegion();
                region.center.latitude = self.thePlacemark!.location!.coordinate.latitude;
                region.center.longitude = self.thePlacemark!.location!.coordinate.longitude;
                region.span = MKCoordinateSpanMake(spanX, spanY);
                self.navigationMapView.setRegion(region, animated: true)
                self.addAnnotation(placemark:self.thePlacemark!)
            }
        }
    }
    
    func addAnnotation(placemark:CLPlacemark) {
        let point:MKPointAnnotation = MKPointAnnotation();
        point.coordinate = CLLocationCoordinate2DMake(placemark.location!.coordinate.latitude, placemark.location!.coordinate.longitude)
        point.title = placemark.addressDictionary!["Street"].debugDescription
            //[placemark.addressDictionary objectForKey:@];
        point.subtitle = placemark.addressDictionary!["City"].debugDescription
        //[placemark.addressDictionary objectForKey:@"City"];
        self.navigationMapView.addAnnotation(point)
    }
}
