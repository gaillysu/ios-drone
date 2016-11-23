//
//  MyDeviceViewController.swift
//  Drone
//
//  Created by Karl-John on 1/5/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import PagingMenuController
import SnapKit

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
            let options = PagingMenuOptions(controllers: viewControllers)
            let pagingMenuController = PagingMenuController(options: options)
            pagingMenuController.view.frame = CGRect(x: 0, y: -64, width: UIScreen.main.bounds.width, height: self.devicesView.frame.size.height+50)
            addChildViewController(pagingMenuController)
            view.addSubview(pagingMenuController.view)
            pagingMenuController.didMove(toParentViewController: self)
            pagingMenuController.view.snp.makeConstraints { (make) -> Void in
                make.top.equalTo(self.view).offset(0)
            }
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
        
        UIApplication.shared.openURL(URL(string: "")!)
    }
    
    func pushContactsFilterViewController(){
        self.navigationController?.pushViewController(ContactsNotificationViewController(), animated: true)
    }
    
    
    struct PagingMenuOptions: PagingMenuControllerCustomizable {
        var controllers:[UIViewController] = []
        init(controllers:[UIViewController]) {
            self.controllers = controllers
        }
        var componentType: ComponentType {
            return .pagingController(pagingControllers: controllers)
        }
    }
}
