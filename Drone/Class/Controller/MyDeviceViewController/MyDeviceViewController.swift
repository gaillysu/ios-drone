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
    var pagingMenuController:PagingMenuController?
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
        if let pagingMenuController = self.pagingMenuController{
            pagingMenuController.removeFromParentViewController()
            view.willRemoveSubview((self.pagingMenuController?.view)!)
            self.pagingMenuController = nil
        }
        
        for cont in viewControllers {
            view.willRemoveSubview(cont.view!)
            cont.removeFromParentViewController()
        }
        viewControllers.removeAll()
        for _ in UserDevice.findAll() {
            let viewController = DeviceViewController()
            viewController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.devicesView.frame.size.height)
            viewControllers.append(viewController)
        }
        
        if(viewControllers.count > 0){
            viewControllers[0].leftRightButtonsNeeded = false
            let options = PagingMenuOptions(controllers: viewControllers)
            pagingMenuController = PagingMenuController(options: options)
            if let pagingMenuController = self.pagingMenuController{
                pagingMenuController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.noDeviceView.frame.height)
                addChildViewController(pagingMenuController)
                devicesView.addSubview(pagingMenuController.view)
                pagingMenuController.view.leftAnchor.constraint(equalTo: self.devicesView.leftAnchor).isActive = true
                pagingMenuController.view.topAnchor.constraint(equalTo: self.devicesView.topAnchor).isActive = true
                pagingMenuController.view.rightAnchor.constraint(equalTo: self.devicesView.rightAnchor).isActive = true
                pagingMenuController.view.bottomAnchor.constraint(equalTo: self.devicesView.bottomAnchor).isActive = true
                self.noDeviceView.isHidden = true
            }
        } else {
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
