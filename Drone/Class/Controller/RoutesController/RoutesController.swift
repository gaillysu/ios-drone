//
//  RoutesController.swift
//  Drone
//
//  Created by Cloud on 2017/5/10.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit
import MapKit
import SwiftEventBus

class RoutesController: UIViewController {
    @IBOutlet weak var routesSegmented: UISegmentedControl!
    @IBOutlet weak var backButton:UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    var placemarks:CLPlacemark?
    
    fileprivate var routeArray:[MKRoute] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.routesSegmented.removeAllSegments();
        calculateRoute()
    }
    
    func calculateRoute() {
        let placemark:MKPlacemark = MKPlacemark(placemark: placemarks!)
        placemark.calculateRoute { (route, error) in
            if error == nil {
                for (index,value) in route!.enumerated(){
                    self.routeArray.append(value)
                    self.routesSegmented.insertSegment(withTitle: "Route \(index+1)", at: index, animated: false)
                }
            }
        }
    }

    @IBAction func routesSelectedAction(_ sender: Any) {
        if routesSegmented.isEqual(sender) {
            let route = self.routeArray[routesSegmented.selectedSegmentIndex]
            setLabelValue(route: route)
            
            let postRoute:PostRoutes = PostRoutes(mPlacemarks: placemarks!, mRoute: route)
            SwiftEventBus.post(SEARCH_ACTION_CLICK, sender: postRoute)
        }
        
        if backButton.isEqual(sender) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func setLabelValue(route:MKRoute) {
        timerLabel.text = route.expectedTravelTime.timeConvertString()
        distanceLabel.text = route.distance.distanceConvertMetricString()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

}
