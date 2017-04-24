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
                self.connectionView.isHidden = true
            }else{
                self.connectionFailView.isHidden = false
                self.connectionView.isHidden = true
            }
        }
        
        //Search device cycle timer ,13s again
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(reSearchTimerAction(_:)), userInfo: nil, repeats: true)
    }
    
    override func viewDidLayoutSubviews() {
        watchImage.image = UIImage(named: watchName)
    }
    
    //Search device until find
    func reSearchTimerAction(_ timer:Timer) {
//        if AppDelegate.getAppDelegate().isConnected() {
//            timer.invalidate()
//        }else{
//        self.navigationItem.setHidesBackButton(false, animated: true)
//            self.connectionFailView.isHidden = false
//            self.connectionView.isHidden = true
//            self.previousButton.isHidden = false
//        }
        
        self.connectedView.isHidden = false
        self.connectionView.isHidden = true

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
            AppDelegate.getAppDelegate().startConnect()
        }
    }
}
