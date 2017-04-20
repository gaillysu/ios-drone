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
        addCloseButton(#selector(dismissViewController))
    }
    
    func dismissViewController(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
            pagingMenuController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.noDeviceView.frame.size.height)
            addChildViewController(pagingMenuController)
            view.addSubview(pagingMenuController.view)
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
