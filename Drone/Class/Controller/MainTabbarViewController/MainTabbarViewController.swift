//
//  MainTabbarViewController.swift
//  Drone
//
//  Created by leiyuncun on 16/4/19.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit

let nDroneAnalysisHeight:CGFloat = 61
let nDroneTabbarHeight:CGFloat = 49
let nDroneBtnWidth:CGFloat = nDroneTabbarHeight
let nDroneBtnHeight:CGFloat = 50

class MainTabbarViewController: UITabBarController {

    
    init() {
        super.init(nibName: "MainTabbarViewController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.hidden = true
        self.view.backgroundColor = UIColor.whiteColor()

        let tabbar:DroneTabbar = DroneTabbar()
        let frame:CGRect = tabbar.frame;
        tabbar.frame = CGRectMake(0, UIScreen.mainScreen().bounds.size.height-nDroneTabbarHeight, frame.size.width, nDroneTabbarHeight);
        tabbar.backgroundColor = UIColor(patternImage: UIImage(named: "gradually")!)
        self.view.addSubview(tabbar)

        let analysisView:UIView = UIView();
        analysisView.center = CGPointMake(UIScreen.mainScreen().bounds.size.width*0.5, UIScreen.mainScreen().bounds.size.height-(nDroneAnalysisHeight*0.5));
        analysisView.bounds = CGRectMake(0, 0, nDroneTabbarHeight, nDroneAnalysisHeight);
        analysisView.backgroundColor = UIColor(patternImage: UIImage(named: "tabbar_ background")!)

        let analysisBtn:UIButton = UIButton();
        analysisBtn.setBackgroundImage(UIImage(named: ""), forState: UIControlState.Normal)
        analysisBtn.setBackgroundImage(UIImage(named: ""), forState: UIControlState.Highlighted)
        analysisBtn.frame = CGRectMake(0, 5, nDroneTabbarHeight, nDroneAnalysisHeight);
        analysisBtn.tag = 2;
        analysisBtn.addTarget(self, action: #selector(MainTabbarViewController.cameraClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        analysisView.addSubview(analysisBtn)
        self.view.addSubview(analysisView)

        self.initViewController()
    }

    func cameraClick(sender:UIButton) {

    }

    func initViewController() {
        let nav1:UINavigationController = UINavigationController(rootViewController: WorldClockController())
        let nav2:UINavigationController = UINavigationController(rootViewController: StepsViewController())
        let nav3:UINavigationController = UINavigationController(rootViewController: SleepViewController())
        self.setViewControllers([nav1,nav2,nav3], animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
