//
//  MyDeviceViewController.swift
//  Drone
//
//  Created by Karl-John on 1/5/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import PagingMenuController
import BRYXBanner

class MyDeviceViewController: BaseViewController {
    @IBOutlet weak var devicesView: UIView!
    @IBOutlet weak var noDeviceView: UIView!
    @IBOutlet weak var myDevicePagesView: UIView!
    @IBOutlet weak var addButton: UIButton!
    
    
    var viewControllers:[DeviceViewController] = []
    
    init() {
        super.init(nibName: "MyDeviceViewController", bundle: Bundle.main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Watches"
        addCloseButton(#selector(dismissViewController))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadDeviceControllers()
    }
    
    func dismissViewController(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func reloadDeviceControllers() {
        for cont in viewControllers {
            cont.removeFromParentViewController()
        }
        viewControllers.removeAll()
        let deviceArray = DataBaseManager.manager.getAllDevice()
        for _ in deviceArray {
            let viewController = DeviceViewController()
            viewController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.devicesView.frame.size.height)
            viewControllers.append(viewController)
        }
        
        if(viewControllers.count > 0){
            viewControllers[0].leftRightButtonsNeeded = false;
            let options = PagingMenuOptions(controllers: viewControllers)
            let pagingMenuController = PagingMenuController(options: options)
            pagingMenuController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.noDeviceView.frame.size.height - 67.0)
            addChildViewController(pagingMenuController)
            view.addSubview(pagingMenuController.view)
            pagingMenuController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
            pagingMenuController.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            pagingMenuController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
            pagingMenuController.view.bottomAnchor.constraint(equalTo: addButton.topAnchor).isActive = true
            pagingMenuController.didMove(toParentViewController: self)
            self.noDeviceView.isHidden = true
        }else{
            self.noDeviceView.isHidden = false
        }
    }
    
    @IBAction func addDeviceAction(_ sender: AnyObject) {
        if !(getAppDelegate().getMconnectionController()?.isBluetoothEnabled())! {
            let banner = Banner(title: NSLocalizedString(NSLocalizedString("bluetooth_not_on", comment: ""), comment: ""), subtitle: nil, image: nil, backgroundColor:UIColor.getBaseColor())
            banner.dismissesOnTap = true
            banner.show(duration: 1.2)
            return
        }
        let navigationController = makeStandardUINavigationController(WhichDeviceViewController(toMenu: false))
        self.navigationController?.present(navigationController, animated: true, completion: nil)
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
