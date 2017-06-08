//
//  CLGeocoder+Extension.swift
//  Drone
//
//  Created by Cloud on 2017/5/9.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit
import CoreLocation

extension CLGeocoder {
     func reverseGeocodeLocationInfo(location:CLLocation,completion: @escaping ((locationLong:String?,locationShort:String?,name:String?,cityName:String?), _ error:Error?) -> Void) {
        var locationLong:String?
        var locationShort:String?
        var cityName:String?
        
        self.reverseGeocodeLocation(location) { (placemarks, error) -> Void in
            if error != nil {
                return
            }
            let placeArray = placemarks as [CLPlacemark]!
            let placeMark: CLPlacemark! = placeArray?.first
            
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
                cityName = area
            }
            
            if let _ = locationLong, let _ = locationShort {
                completion((locationLong,locationShort,placeMark.name,cityName),nil)
            }else{
                let error = NSError(domain: "geocode error", code: -1, userInfo: nil) as Error
                completion((nil,nil,nil,nil),error)
            }
        }
    }
}
