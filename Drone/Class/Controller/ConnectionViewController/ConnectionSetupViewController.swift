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
    private var toMenu:Bool = true;
    init(toMenu:Bool) {
        self.toMenu = toMenu
        super.init(nibName: "ConnectionSetupViewController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.nextB.hidden = true
        AppDelegate.getAppDelegate().startConnect()

        SwiftEventBus.onMainThread(self, name: SWIFTEVENT_BUS_CONNECTION_STATE_CHANGED_KEY) { (notification) -> Void in
            let connectionState:Bool = notification.object as! Bool
            if(connectionState){
                self.nextB.hidden = false
                self.connectedView.hidden = false
                self.connectionView.hidden = true
            }else{
                self.connectionFailView.hidden = false
                self.connectionView.hidden = true
            }
        }

        //Search device cycle timer ,13s again
        NSTimer.scheduledTimerWithTimeInterval(13, target: self, selector: #selector(reSearchTimerAction(_:)), userInfo: nil, repeats: true)
    }

    override func viewDidLayoutSubviews() {
        watchImage.image = UIImage(named: watchName)
    }
    
    //Search device until find
    func reSearchTimerAction(timer:NSTimer) {
        if AppDelegate.getAppDelegate().isConnected() {
            timer.invalidate()
        }else{
            self.connectionFailView.hidden = false
            self.connectionView.hidden = true
            if(self.toMenu){
                AppDelegate.getAppDelegate().startConnect()
            }else{
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func buttonActionManager(sender: AnyObject) {
        if sender.isEqual(nextB) {
            self.dismissViewControllerAnimated(true, completion: { 
                AppDelegate.getAppDelegate().setUserProfile()
            })
        }

        if sender.isEqual(retryButton) {
            self.connectionFailView.hidden = true
            self.connectionView.hidden = false
        }
    }
}
