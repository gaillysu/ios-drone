//
//  TimeTabViewController.swift
//  Drone
//
//  Created by Karl-John Chow on 20/4/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import Foundation
import UIKit
import Font_Awesome_Swift
import RealmSwift
import MRProgress

class TimeTabViewController: UITabBarController {
    
    var worldClockViewController = WorldClockViewController()
    
    var firstTimeInitialize = true
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBar.backgroundColor = UIColor.white
        tabBar.tintColor = UIColor.getBaseColor()
        // Create Tab two
        let worldClockTab = worldClockViewController
        let worldClockTabItem = UITabBarItem(title: "World Clock", image: UIImage(named: "icon_world_clock_tab")!, selectedImage: UIImage(named: "icon_world_clock_tab")!)
        worldClockTab.tabBarItem = worldClockTabItem
        
        let alarmViewController = AlarmViewController()
        let alarmTab = UITabBarItem(title: "Alarm", image: UIImage(named: "icon_alarm")!, selectedImage: UIImage(named: "icon_alarm")!)
        alarmViewController.tabBarItem = alarmTab
        
        let timerViewController = TimerViewController()
        let timerTab = UITabBarItem(title: "Timer", image: UIImage(named: "icon_timer")!, selectedImage: UIImage(named: "icon_timer")!)
        timerViewController.tabBarItem = timerTab
        
        let timeSettingsViewController = TimeSettingsViewController()
        let timeSettingsTab = UITabBarItem(title: "Settings", image: UIImage(named: "icon_settings")!, selectedImage: UIImage(named: "icon_settings")!)
        timeSettingsViewController.tabBarItem = timeSettingsTab
        self.viewControllers = [worldClockTab, alarmViewController, timerViewController, timeSettingsViewController]
        self.addCloseButton(#selector(dismissTabViewController))
        if firstTimeInitialize {
            firstTimeInitialize = false
            self.tabBar(self.tabBar, didSelect: (self.viewControllers?[0].tabBarItem)!)
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        self.navigationItem.title = item.title
        if let index = self.tabBar.items?.index(of: item){
            switch index {
            case 0:
                self.addPlusButton(#selector(addWorldClock))
            case 1:
                self.addPlusButton(#selector(addAlarm))
            default:
                self.navigationItem.rightBarButtonItem = nil
                break
            }
        }
    }
    
    func dismissTabViewController(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func addWorldClock(){
        var worldClockArray:[City] = []
        try! Realm().objects(City.self)
            .filter("selected = true")
            .sorted(by: { ($0.timezone?.getOffsetFromUTC())! < ($1.timezone?.getOffsetFromUTC())! })
            .forEach({ worldClockArray.append($0) })
        
        if worldClockArray.count >= 5 {
            let alert:UIAlertController = UIAlertController(title: "World Clock", message: NSLocalizedString("only_5_world_clock", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
             return
        }
        let selectCityController: AddWorldClockViewController = AddWorldClockViewController()
        let navigationController: UINavigationController = UINavigationController(rootViewController: selectCityController)
        navigationController.navigationBar.setBackgroundImage(UIImage(named: "gradually"), for: UIBarMetrics.default)
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        navigationController.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        present(navigationController, animated: true, completion: nil)
        //self.present(self.makeStandardUINavigationController(AddWorldClockViewController()), animated: true, completion: nil)
    }
    
    func addAlarm(){
        self.navigationController?.pushViewController(AddAlarmViewController(viewModel: AddAlarmViewModel()), animated: true)
    }
    
    
}
