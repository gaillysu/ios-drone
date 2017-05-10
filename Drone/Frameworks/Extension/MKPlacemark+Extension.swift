//
//  MKPlacemark+Extension.swift
//  Drone
//
//  Created by Cloud on 2017/5/8.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit
import MapKit

extension MKPlacemark {
    func calculateRoute(completion: @escaping (_ route:[MKRoute]?, _ error:Error?) -> Void) {
        let directionsRequest:MKDirectionsRequest = MKDirectionsRequest()
        let placemark:MKPlacemark = MKPlacemark(placemark: self)
        directionsRequest.source = MKMapItem.forCurrentLocation()
        directionsRequest.destination = MKMapItem(placemark: placemark)
        directionsRequest.transportType = MKDirectionsTransportType.automobile;
        let directions:MKDirections = MKDirections(request: directionsRequest)
        directions.calculate { (response, error) in
            if error == nil {
                completion(response?.routes, nil)
            }else{
                completion(nil, NSError(domain: "calculate route error", code: -30, userInfo: nil))
            }
        }
    }
}
