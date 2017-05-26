//
//  ConnectionViewController.swift
//  Drone
//
//  Created by leiyuncun on 16/4/21.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit
import SwiftEventBus

class ConnectionSetupViewController: UIViewController {
    
    
    @IBOutlet weak var connectedView: UIView!
    @IBOutlet weak var connectionFailView: UIView!
    @IBOutlet weak var connectionView: UIView!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var watchImage: UIImageView!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var connectedStatusLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var initializationTimer:Timer?
    
    var watchName:String = ""
    fileprivate var toMenu:Bool = true;
    init(toMenu:Bool) {
        self.toMenu = toMenu
        super.init(nibName: "ConnectionSetupViewController", bundle: Bundle.main)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Connect"
        self.navigationItem.setHidesBackButton(true, animated: false)
        AppDelegate.getAppDelegate().connectNew()
        _ = SwiftEventBus.onMainThread(self, name: SWIFTEVENT_BUS_CONNECTION_STATE_CHANGED_KEY) { (notification) -> Void in
            let connectionState:Bool = notification.object as! Bool
            
            if(connectionState){
                self.connectedView.isHidden = false
                self.activityIndicator.startAnimating()
                self.connectionView.isHidden = true
                self.initializationTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.showInitializingError(_:)), userInfo: nil, repeats: false)
            }else{
                self.connectionFailView.isHidden = false
                self.connectionView.isHidden = true
            }
        }
        
        _ = SwiftEventBus.onMainThread(self, name: SWIFTEVENT_BUS_INITIALIZATION_COMPLETED) { (notification) -> Void in
            self.initializationTimer?.invalidate()
            self.activityIndicator.isHidden = true
            self.nextButton.isHidden = false
            self.connectedStatusLabel.text = "Connected"
        }
        _ = SwiftEventBus.onMainThread(self, name: SWIFTEVENT_BUS_FIRMWARE_VERSION_RECEIVED_KEY) { (notification) -> Void in
            if let version = notification.object as? PostWatchVersionData{
                self.versionLabel.text = "version: \(version.watchVersion)"
            }
        }
        
        //Search device cycle timer ,13s again
        Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(reSearchTimerAction(_:)), userInfo: nil, repeats: true)
    }
    
    override func viewDidLayoutSubviews() {
        watchImage.image = UIImage(named: watchName)
    }
    
    //Search device until find
    func reSearchTimerAction(_ timer:Timer) {
        if AppDelegate.getAppDelegate().isConnected() {
            timer.invalidate()
        }else{
            self.navigationItem.setHidesBackButton(false, animated: true)
            self.connectionFailView.isHidden = false
            self.connectionView.isHidden = true
        }
    }
    
    @IBAction func buttonActionManager(_ sender: AnyObject) {
        if sender.isEqual(nextButton) {
            AppDelegate.getAppDelegate().setUserProfile()
            self.navigationController?.pushViewController(CalibrateHourViewController(), animated: true)
        }
        if sender.isEqual(retryButton) {
            self.navigationItem.setHidesBackButton(true, animated: true)
            self.connectionFailView.isHidden = true
            self.connectionView.isHidden = false
            AppDelegate.getAppDelegate().connectNew()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SwiftEventBus.unregister(self)
    }
    
    
    func showInitializingError(_ timer:Timer) {
        timer.invalidate()
        self.connectionFailView.isHidden = false
        self.connectedView.isHidden = true
    }
}
