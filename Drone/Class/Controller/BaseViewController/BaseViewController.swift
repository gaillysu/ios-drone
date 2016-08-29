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
    
    func delay(seconds seconds:Double, completion:()->()) {
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))
        
        dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) {
            completion()
        }
    }
}

class BaseViewController: UIViewController {
    override func viewDidLoad() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "gradually"), forBarMetrics: UIBarMetrics.Default)
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
        navigationController.navigationBar.tintColor = UIColor.whiteColor()

        navigationController.navigationBar.hidden = false
        navigationController.navigationItem.setHidesBackButton(false, animated: true)
        return navigationController
    }
    
    func addPlusButton(action:Selector){
        self.navigationItem.rightBarButtonItem = self.createBarButtonItem(withAction: action, withImage: UIImage(named: "addbutton")!);
    }
    
    func addCloseButton(action:Selector){
        self.navigationItem.leftBarButtonItem = self.createBarButtonItem(withAction: action, withImage: UIImage(named: "closebutton")!);
    }
    
    private func createBarButtonItem(withAction action:Selector, withImage image:UIImage) -> UIBarButtonItem{
        let button: UIButton = UIButton(type: UIButtonType.Custom)
        button.setImage(image, forState: UIControlState.Normal)
        button.addTarget(self, action: action, forControlEvents: UIControlEvents.TouchUpInside)
        button.frame = CGRectMake(0, 0, 30, 30)
        return UIBarButtonItem(customView: button)
    }
    
    func getAppDelegate() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
}