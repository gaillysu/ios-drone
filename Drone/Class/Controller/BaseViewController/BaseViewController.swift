//
//  BaseViewController.swift
//  Drone
//
//  Created by Karl Chow on 3/8/16.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

class BaseViewController: UIViewController {
    override func viewDidLoad() {
        if((UIDevice.currentDevice().systemVersion as NSString).floatValue>7.0){
            self.edgesForExtendedLayout = UIRectEdge.None;
            self.extendedLayoutIncludesOpaqueBars = false;
            self.modalPresentationCapturesStatusBarAppearance = false;
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func makeStandardUINavigationController(rootViewController:UIViewController) -> UINavigationController{
        let navigationController:UINavigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.navigationBar.setBackgroundImage(UIImage(named: "gradually"), forBarMetrics: UIBarMetrics.Default)
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationController.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        navigationController.navigationBar.barTintColor = UIColor.getBaseColor()
        navigationController.navigationBar.hidden = false
        return navigationController
    }
    
    
    func getAppDelegate() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
}