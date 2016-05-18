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
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "Watches"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buyButton.titleLabel?.textAlignment = NSTextAlignment.Center
        
    }
    
    override func viewDidAppear(animated: Bool) {
        var viewControllers:[DeviceViewController] = []
        let deviceArray:NSArray = UserDevice.getAll()
        for device in deviceArray {
            let viewController = DeviceViewController()
            viewController.view.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, self.devicesView.frame.size.height)
            viewControllers.append(viewController)
            
        }
        
        if(viewControllers.count == 1){
            viewControllers[0].leftRightButtonsNeeded = false;
        }else if(viewControllers.count == 0) {
            self.noDeviceView.hidden = false
        }else{
            let options = PagingMenuOptions()
            options.menuHeight = 0;
            options.menuDisplayMode = .Standard(widthMode: PagingMenuOptions.MenuItemWidthMode.Flexible, centerItem: true, scrollingMode: PagingMenuOptions.MenuScrollingMode.ScrollEnabled)
            let pagingMenuController = PagingMenuController(viewControllers: viewControllers, options: options)
            pagingMenuController.view.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, self.devicesView.frame.size.height)
            self.addChildViewController(pagingMenuController)
            self.devicesView.addSubview(pagingMenuController.view)
            pagingMenuController.didMoveToParentViewController(self)
            self.noDeviceView.hidden = true
            
        }
    }
    
    @IBAction func addDeviceAction(sender: AnyObject) {
        let navigationController:UINavigationController = UINavigationController(rootViewController: WhichDeviceViewController(toMenu: false))
        navigationController.navigationBar.hidden = true
        self.navigationController?.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func buyButtonAction(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://www.hsn.com/shop/drone-presented-by-shaquille-oneal/13040")!)
    }
    
    func pushContactsFilterViewController(){
        self.navigationController?.pushViewController(ContactsNotificationViewController(), animated: true)
    }
}
