//
//  LocationExtension.swift
//  Drone
//
//  Created by Cloud on 2017/4/18.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit

import Foundation
import CoreLocation

extension CLLocation{
    
    func reverseGeocodeLocationInfo(completion: @escaping ((locationLong:String?,locationShort:String?), _ error:Error?) -> Void) {
        var locationLong:String?
        var locationShort:String?
        CLGeocoder().reverseGeocodeLocation(self) { (placemarks, error) -> Void in
            if error != nil {
                return
            }
            let placeArray = placemarks as [CLPlacemark]!
            let placeMark: CLPlacemark! = placeArray?[0]
            
            if let street = placeMark.thoroughfare {
                locationShort = "\(street)"
                locationLong = "\(street)"
            }
            
            if let district = placeMark.subLocality, let _ = locationLong, let _ = locationShort {
                locationLong = locationLong! + ", \(district)"
            }
            
            if let area = placeMark.locality, let _ = locationLong, let _ = locationShort {
                locationShort = locationShort! + ", \(area)"
                locationLong = locationLong! + ", \(area)"
            }
            
            if let _ = locationLong, let _ = locationShort {
                completion((locationLong,locationShort),nil)
            }else{
                let error = NSError(domain: "geocode error", code: -1, userInfo: nil) as Error
                completion((nil,nil),error)
            }
        }
    }
    
}
