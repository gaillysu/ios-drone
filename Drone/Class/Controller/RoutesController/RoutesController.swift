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
import GoogleMaps

class RoutesController: UIViewController {
    @IBOutlet weak var routesSegmented: UISegmentedControl!
    @IBOutlet weak var backButton:UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var takeTimeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var alternativeLabel: UILabel!
    @IBOutlet weak var timerConstraint: NSLayoutConstraint!
    
    fileprivate let routeMode:[String] = ["Driving","Walking","Transit"]
    
    var googleMapView:GMSMapView?
    
    var geocodeModel:GoogleMapsGeocodeModel?
    
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
        
        self.routesSegmented.removeAllSegments()
        
        for (index,value) in routeMode.enumerated() {
            self.routesSegmented.insertSegment(withTitle: value, at: index, animated: false)
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
        guard geocodeModel?.geometry_location_lat != nil || geocodeModel?.geometry_location_lng != nil || LocationManager.manager.currentLocation != nil else {
            DRHUD.showHudAndDissmiss(title: "not destination location", subtitle: nil, duration: 1.2, type: DRHUD.DRHudType.error, completion: nil)
            return
        }
        
        let mode = routeMode[index]
        
        let startLocation_lat:String = "\(LocationManager.manager.currentLocation!.coordinate.latitude)"
        let startLocation_lng:String = "\(LocationManager.manager.currentLocation!.coordinate.longitude)"
        let startAddres:String = startLocation_lat+","+startLocation_lng
        
        let endLocation_lat:String = geocodeModel!.geometry_location_lat
        let endLocation_lng:String = geocodeModel!.geometry_location_lng
        let endAddres:String = endLocation_lat+","+endLocation_lng
        
        GoogleMapNetworkManager.manager.getGoogleMapsDirections(startAddres: startAddres, endAddres: endAddres, mode: mode) { (directionsModel) in
            if directionsModel != nil {
                var pathArray:[CLLocationCoordinate2D] = []
                directionsModel?.routes.forEach({ (routesModel) in
                    self.setLabelValue(takeTime: routesModel.duration_text, distance: routesModel.distance_text, routeText: "")
                    for (index,routesStepsModel) in routesModel.routesSteps.enumerated() {
                        let latDiff = routesStepsModel.end_location_lat - routesStepsModel.start_location_lat
                        let lngDiff = routesStepsModel.end_location_lng - routesStepsModel.start_location_lng
                        let location1:CLLocation = CLLocation(latitude: routesStepsModel.start_location_lat, longitude: routesStepsModel.start_location_lng)
                        let location2:CLLocation = CLLocation(latitude: routesStepsModel.end_location_lat, longitude: routesStepsModel.end_location_lng)
                        let meters:CLLocationDistance = location1.distance(from: location2)
                        
                        if meters > 300 {
                            let insertCount = Int(meters/300)
                            let insertLat:Double = latDiff/Double(insertCount)
                            let insertLng:Double = lngDiff/Double(insertCount)
                            for index in 0..<insertCount {
                                let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude:routesStepsModel.start_location_lat+(insertLat*Double(index)), longitude: routesStepsModel.start_location_lng+(insertLng*Double(index)))
                                pathArray.append(coordinate)
                            }
                        }

                    }
                })
                
                let pathFormat = self.pathFormat(coordinate: pathArray)
                GoogleMapRoadsNetworkManager.manager.snaptoRoadsRequest(path: pathFormat, responseBlock: { (roadsArray) in
                    if roadsArray != nil {
                        let path = GMSMutablePath()
                        var lastLocation:CLLocationCoordinate2D?
                        roadsArray?.forEach({ (roadsModel) in
                            let coordinate = CLLocationCoordinate2D(latitude:roadsModel.location_latitude, longitude: roadsModel.location_longitude)
                            path.add(coordinate)
                            lastLocation = coordinate
                        })
                        
                        let line = GMSPolyline(path: path)
                        line.strokeWidth = 6
                        line.strokeColor = .getBaseColor()
                        line.geodesic = true
                        
                        let postRoute:PostRoutes = PostRoutes(line: line)
                        postRoute.endLocation = lastLocation
                        SwiftEventBus.post(SEARCH_ACTION_CLICK, sender: postRoute)
                    }
                })
            }
        }
        
    }
    
    func setLabelValue(takeTime:String, distance:String ,routeText:String) {
        takeTimeLabel.text = takeTime
        distanceLabel.text = distance
        alternativeLabel.text = routeText
    }
    
    func startTimer() {
        startDate = Date()
        statrtTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction(_:)), userInfo: nil, repeats: true)
        
        displayTimer()
        
        //AppDelegate.getAppDelegate().startNavigation(name: placemarks!.name!)
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
            if let location = LocationManager.manager.currentLocation {
                let current:CLLocation = location
//                let before:CLLocation = placemarks!.location!
//                let meters = current.distance(from: before)
//                AppDelegate.getAppDelegate().updateNavigation(distance: Int(meters))
            }
        }
    }
    
    fileprivate func pathFormat(coordinate:[CLLocationCoordinate2D]) -> String {
        var locationPath:String = ""
        coordinate.forEach { (location) in
            locationPath.append("|\(location.latitude),\(location.longitude)")
        }
        if locationPath.characters.count>0 {
            locationPath.remove(at: locationPath.startIndex)
        }
        return locationPath
    }
}
