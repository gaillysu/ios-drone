//
//  MyDeviceViewController.swift
//  Drone
//
//  Created by Karl-John on 1/5/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import PagingMenuController

class MyDeviceViewController: BaseViewController {
    @IBOutlet weak var devicesView: UIView!
    @IBOutlet weak var noDeviceView: UIView!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var myDevicePagesView: UIView!
    
    init() {
        super.init(nibName: "MyDeviceViewController", bundle: NSBundle.mainBundle())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.navigationItem.title = "Watch Settings"
        
        buyButton.titleLabel?.textAlignment = NSTextAlignment.Center
        let viewController = DeviceViewController()
        let viewController2 = DeviceViewController()
        let viewControllers = [viewController,viewController2]
        if(viewControllers.count == 1){
            viewControllers[0].leftRightButtonsNeeded = false;
        }
        
        let options = PagingMenuOptions()
        options.menuHeight = 0;
        options.menuDisplayMode = .Standard(widthMode: PagingMenuOptions.MenuItemWidthMode.Fixed(width: UIScreen.mainScreen().bounds.width), centerItem: true, scrollingMode: PagingMenuOptions.MenuScrollingMode.ScrollEnabled)
        let pagingMenuController = PagingMenuController(viewControllers: viewControllers, options: options)
        pagingMenuController.view.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
        self.addChildViewController(pagingMenuController)
        self.devicesView.addSubview(pagingMenuController.view)
        pagingMenuController.didMoveToParentViewController(self)
        self.noDeviceView.hidden = true
    }
    
    @IBAction func addDeviceAction(sender: AnyObject) {
        let navigationController:UINavigationController = UINavigationController(rootViewController: WhichDeviceViewController(toMenu: false))
        navigationController.navigationBar.hidden = true
        self.navigationController?.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func buyButtonAction(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://www.hsn.com/shop/drone-presented-by-shaquille-oneal/13040")!)
    }
}