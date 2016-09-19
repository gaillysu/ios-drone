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
    
    func delay(seconds:Double, completion:@escaping ()->()) {
        let popTime = DispatchTime.now() + Double(Int64( Double(NSEC_PER_SEC) * seconds )) / Double(NSEC_PER_SEC)
        
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.low).asyncAfter(deadline: popTime) {
            completion()
        }
    }
}

class BaseViewController: UIViewController {
    override func viewDidLoad() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "gradually"), for: UIBarMetrics.default)
        if((UIDevice.current.systemVersion as NSString).floatValue>7.0){
            self.edgesForExtendedLayout = UIRectEdge();
            self.extendedLayoutIncludesOpaqueBars = false;
            self.modalPresentationCapturesStatusBarAppearance = false;
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    
    func makeStandardUINavigationController(_ rootViewController:UIViewController) -> UINavigationController{
        let navigationController:UINavigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.navigationBar.setBackgroundImage(UIImage(named: "gradually"), for: UIBarMetrics.default)
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        navigationController.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        navigationController.navigationBar.barTintColor = UIColor.getBaseColor()
        navigationController.navigationBar.tintColor = UIColor.white

        navigationController.navigationBar.isHidden = false
        navigationController.navigationItem.setHidesBackButton(false, animated: true)
        return navigationController
    }
    
    func addPlusButton(_ action:Selector){
        self.navigationItem.rightBarButtonItem = self.createBarButtonItem(withAction: action, withImage: UIImage(named: "addbutton")!);
    }
    
    func addCloseButton(_ action:Selector){
        self.navigationItem.leftBarButtonItem = self.createBarButtonItem(withAction: action, withImage: UIImage(named: "closebutton")!);
    }
    
    fileprivate func createBarButtonItem(withAction action:Selector, withImage image:UIImage) -> UIBarButtonItem{
        let button: UIButton = UIButton(type: UIButtonType.custom)
        button.setImage(image, for: UIControlState())
        button.addTarget(self, action: action, for: UIControlEvents.touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        return UIBarButtonItem(customView: button)
    }
    
    func getAppDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
}
