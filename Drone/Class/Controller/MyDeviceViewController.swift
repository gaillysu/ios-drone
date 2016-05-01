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
        buyButton.titleLabel?.textAlignment = NSTextAlignment.Center
        let viewController = DeviceViewController()
        viewController.title = "My Device"
        let viewControllers = [viewController]
        
        let options = PagingMenuOptions()
        options.menuItemMargin = 5
        options.menuDisplayMode = .SegmentedControl
        let pagingMenuController = PagingMenuController(viewControllers: viewControllers, options: options)
        
        self.addChildViewController(pagingMenuController)
        self.devicesView.addSubview(pagingMenuController.view)
        pagingMenuController.didMoveToParentViewController(self)
        
    }
    
    @IBAction func addDeviceAction(sender: AnyObject) {
    }
    
    @IBAction func buyButtonAction(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://www.hsn.com/shop/drone-presented-by-shaquille-oneal/13040")!)
    }
}