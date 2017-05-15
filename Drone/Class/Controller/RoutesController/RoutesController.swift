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
import SwiftyTimer

class RoutesController: UIViewController {
    @IBOutlet weak var routesSegmented: UISegmentedControl!
    @IBOutlet weak var backButton:UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var takeTimeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var alternativeLabel: UILabel!
    @IBOutlet weak var timerConstraint: NSLayoutConstraint!
    
    var placemarks:CLPlacemark?
    
    fileprivate var routeArray:[MKRoute] = []
    fileprivate var statrtTimer:Timer?
    fileprivate var startDate:Date?
    fileprivate lazy var dateFormat: DateFormatter = {
        let formatter:DateFormatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.routesSegmented.removeAllSegments();
        calculateRoute()

    }
    
    func calculateRoute() {
        let placemark:MKPlacemark = MKPlacemark(placemark: placemarks!)
        placemark.calculateRoute { (route, error) in
            if error == nil {
                for value in route! {
                    self.routeArray.append(value)
                }
                
                self.routeArray.sort{
                    switch ($0, $1) {
                    case let (aCode, bCode):
                        return aCode.distance < bCode.distance
                    }
                }
                
                for (index,_) in self.routeArray.enumerated() {
                    self.routesSegmented.insertSegment(withTitle: "Route \(index+1)", at: index, animated: false)
                }
                
                self.routesSegmented.selectedSegmentIndex = 0
                self.selectedRoutes(index: 0)
            }
        }
    }

    @IBAction func routesSelectedAction(_ sender: Any) {
        if routesSegmented.isEqual(sender) {
            selectedRoutes(index: routesSegmented.selectedSegmentIndex)
        }
        
        if backButton.isEqual(sender) {
            if statrtTimer != nil {
                let alertControl:UIAlertController = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("stop_navigation_warning_message", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                let alertAction:UIAlertAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.cancel, handler: { (action) in
                    
                })
                alertControl.addAction(alertAction)
                self.present(alertControl, animated: true, completion: nil)
            }else{
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        if startButton.isEqual(sender) {
            if let title = startButton.titleLabel?.text {
                if title == "Start" {
                    startTimer()
                    AppDelegate.getAppDelegate().setNavigation(state: true)
                }else{
                    stopTimer()
                    AppDelegate.getAppDelegate().setNavigation(state: false)
                }
            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
}

extension RoutesController {
    func selectedRoutes(index:Int) {
        let route = self.routeArray[index]
        var routeString = ""
        if index == 0 {
            routeString = "Shortest distance"
        }else{
            routeString = "Alternative";
        }
        setLabelValue(route: route,routeText: routeString)
        
        let postRoute:PostRoutes = PostRoutes(mPlacemarks: placemarks!, mRoute: route)
        SwiftEventBus.post(SEARCH_ACTION_CLICK, sender: postRoute)
    }
    
    func setLabelValue(route:MKRoute,routeText:String) {
        takeTimeLabel.text = route.expectedTravelTime.timeConvertString()
        distanceLabel.text = route.distance.distanceConvertMetricString()
        alternativeLabel.text = routeText
    }
    
    func startTimer() {
        startDate = Date()
        statrtTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction(_:)), userInfo: nil, repeats: true)
        
        displayTimer()
        
        AppDelegate.getAppDelegate().startNavigation(name: placemarks!.name!)
    }
    
    func stopTimer() {
        if let timer = statrtTimer,timer.isValid {
            timer.invalidate()
            statrtTimer = nil
        }
        
        hiddenTimer()
        
        AppDelegate.getAppDelegate().stopNavigation()
     }
    
    func timerAction(_ timer:Timer) {
        let difference:TimeInterval = timer.fireDate.timeIntervalSince1970-startDate!.timeIntervalSince1970
        let elapsedDate:TimeInterval = Date().beginningOfDay.timeIntervalSince1970+difference
        let timeZoneString = dateFormat.string(from: Date(timeIntervalSince1970: elapsedDate))
        timerLabel.text = timeZoneString
        
        sendUpdateNavigation(elapsedValue: difference)
    }
    
    func displayTimer() {
        timerLabel.isHidden = false
        timerLabel.text = "00:00:00"
        self.timerConstraint.constant = 30
        self.timerLabel.layoutIfNeeded()
        
        startButton.setTitle("Stop", for: .normal)
        startButton.setTitle("Stop", for: .selected)
        startButton.setTitle("Stop", for: .highlighted)
        
        takeTimeLabel.isHidden = true
        distanceLabel.isHidden = true
        alternativeLabel.isHidden = true
    }
    
    func hiddenTimer() {
        timerLabel.isHidden = true
        timerLabel.text = "00:00:00"
        self.timerConstraint.constant = 85
        self.timerLabel.layoutIfNeeded()
        
        startButton.setTitle("Start", for: .normal)
        startButton.setTitle("Start", for: .selected)
        startButton.setTitle("Start", for: .highlighted)
        
        takeTimeLabel.isHidden = false
        distanceLabel.isHidden = false
        alternativeLabel.isHidden = false
    }
    
    func sendUpdateNavigation(elapsedValue:TimeInterval) {
        let seconds:Int = Int(elapsedValue)
        if seconds%5 == 0 {
            let current:CLLocation = LocationManager.manager.getCurrentLocation()
            let before:CLLocation = placemarks!.location!
            let meters = current.distance(from: before)
            AppDelegate.getAppDelegate().updateNavigation(distance: Int(meters))
        }
    }
}
