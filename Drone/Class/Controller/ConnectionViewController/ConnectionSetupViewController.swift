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
    @IBOutlet weak var nextB: UIButton!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var watchImage: UIImageView!
    
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
        self.nextB.isHidden = true
        AppDelegate.getAppDelegate().startConnect()

        SwiftEventBus.onMainThread(self, name: SWIFTEVENT_BUS_CONNECTION_STATE_CHANGED_KEY) { (notification) -> Void in
            let connectionState:Bool = notification.object as! Bool
            if(connectionState){
                self.nextB.isHidden = false
                self.connectedView.isHidden = false
                self.connectionView.isHidden = true
            }else{
                self.connectionFailView.isHidden = false
                self.connectionView.isHidden = true
            }
        }

        //Search device cycle timer ,13s again
        Timer.scheduledTimer(timeInterval: 13, target: self, selector: #selector(reSearchTimerAction(_:)), userInfo: nil, repeats: true)
    }

    override func viewDidLayoutSubviews() {
        watchImage.image = UIImage(named: watchName)
    }
    
    //Search device until find
    func reSearchTimerAction(_ timer:Timer) {
        if AppDelegate.getAppDelegate().isConnected() {
            timer.invalidate()
        }else{
            self.connectionFailView.isHidden = false
            self.connectionView.isHidden = true
            if(self.toMenu){
                AppDelegate.getAppDelegate().startConnect()
            }else{
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func buttonActionManager(_ sender: AnyObject) {
        if sender.isEqual(nextB) {
            self.dismiss(animated: true, completion: { 
                AppDelegate.getAppDelegate().setUserProfile()
            })
        }

        if sender.isEqual(retryButton) {
            self.connectionFailView.isHidden = true
            self.connectionView.isHidden = false
        }
    }
}
