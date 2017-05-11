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
            if statrtTimer != nil {
                let alertControl:UIAlertController = UIAlertController(title: "exit error", message: "is can not exit in navigation", preferredStyle: UIAlertControllerStyle.alert)
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
    func setLabelValue(route:MKRoute) {
        takeTimeLabel.text = route.expectedTravelTime.timeConvertString()
        distanceLabel.text = route.distance.distanceConvertMetricString()
    }
    
    func startTimer() {
        startDate = Date()
        statrtTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction(_:)), userInfo: nil, repeats: true)
        displayTimer()
        timerLabelAnimate()
    }
    
    func stopTimer() {
        if let timer = statrtTimer,timer.isValid {
            timer.invalidate()
            statrtTimer = nil
        }
        hiddenTimer()
        
        timerLabelAnimate()
     }
    
    func timerAction(_ timer:Timer) {
        let difference:TimeInterval = timer.fireDate.timeIntervalSince1970-startDate!.timeIntervalSince1970
        let elapsedDate:TimeInterval = Date().beginningOfDay.timeIntervalSince1970+difference
        let timeZoneString = dateFormat.string(from: Date(timeIntervalSince1970: elapsedDate))
        timerLabel.text = timeZoneString
    }
    
    func displayTimer() {
        timerLabel.isHidden = false
        timerLabel.text = "00:00:00"
        startButton.setTitle("Stop", for: .normal)
        startButton.setTitle("Stop", for: .selected)
        startButton.setTitle("Stop", for: .highlighted)
    }
    
    func hiddenTimer() {
        timerLabel.isHidden = true
        timerLabel.text = "00:00:00"
        
        startButton.setTitle("Start", for: .normal)
        startButton.setTitle("Start", for: .selected)
        startButton.setTitle("Start", for: .highlighted)
    }
    
    func timerLabelAnimate() {
        if self.timerConstraint.constant > 30 {
            self.timerConstraint.constant = 30
        }else{
            self.timerConstraint.constant = 85
        }
        self.timerLabel.layoutIfNeeded()
    }
}
