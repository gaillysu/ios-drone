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
    var viewControllers:[DeviceViewController] = []
    
    init() {
        super.init(nibName: "MyDeviceViewController", bundle: Bundle.main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Watches"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buyButton.titleLabel?.textAlignment = NSTextAlignment.center
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        for cont in viewControllers {
            cont.removeFromParentViewController()
        }
        viewControllers.removeAll()
        
        let deviceArray:NSArray = UserDevice.getAll()
        for _ in deviceArray {
            let viewController = DeviceViewController()
            viewController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.devicesView.frame.size.height)
            viewControllers.append(viewController)
        }
        
        if(viewControllers.count > 0){
            viewControllers[0].leftRightButtonsNeeded = false;
            let options = PagingMenuOptions()
            options.menuHeight = 0;
            options.menuDisplayMode = .standard(widthMode: PagingMenuOptions.MenuItemWidthMode.flexible, centerItem: true, scrollingMode: PagingMenuOptions.MenuScrollingMode.scrollEnabled)
            let pagingMenuController = PagingMenuController(menuControllerTypes: viewControllers, options: options)
            pagingMenuController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.devicesView.frame.size.height)
            self.addChildViewController(pagingMenuController)
            self.devicesView.addSubview(pagingMenuController.view)
            pagingMenuController.didMove(toParentViewController: self)
            self.noDeviceView.isHidden = true
        }else{
            self.noDeviceView.isHidden = false
        }
    }
    
    
    @IBAction func addDeviceAction(_ sender: AnyObject) {
        let navigationController:UINavigationController = UINavigationController(rootViewController: WhichDeviceViewController(toMenu: false))
        navigationController.navigationBar.isHidden = true
        self.navigationController?.present(navigationController, animated: true, completion: nil)
    }
    
    @IBAction func buyButtonAction(_ sender: AnyObject) {
        UIApplication.shared.openURL(URL(string: "http://www.hsn.com/shop/drone-presented-by-shaquille-oneal/13040")!)
    }
    
    func pushContactsFilterViewController(){
        self.navigationController?.pushViewController(ContactsNotificationViewController(), animated: true)
    }
}
