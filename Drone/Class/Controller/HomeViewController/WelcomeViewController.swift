//
//  HomeViewController.swift
//  Drone
//
//  Created by leiyuncun on 16/4/13.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit
import SDCycleScrollView

class WelcomeViewController: BaseViewController {

    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var scrollView: UIView!
    @IBOutlet weak var loginB: UIButton!
    @IBOutlet weak var registB: UIButton!
    @IBOutlet weak var forgetButton: UIButton!
    
    var fromMenu = false
    
    init(fromMenu: Bool = false) {
        super.init(nibName: "WelcomeViewController", bundle: Bundle.main)
        self.fromMenu = fromMenu
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        headerImage.contentMode = UIViewContentMode.scaleAspectFit;
        loginB.layer.borderWidth = 1
        loginB.layer.borderColor = UIColor(red: 111.0/225.0, green: 113.0/255.0, blue: 121.0/255.0, alpha: 1).cgColor
        registB.layer.borderWidth = 1
        registB.layer.borderColor = UIColor(red: 111.0/225.0, green: 113.0/255.0, blue: 121.0/255.0, alpha: 1).cgColor

        // Do any additional setup after loading the view.
    }

    override func viewDidLayoutSubviews() {
        let sdView:SDCycleScrollView = SDCycleScrollView(frame: CGRect(x: 0, y: 0, width: scrollView.bounds.size.width, height: scrollView.frame.size.height), shouldInfiniteLoop: true, imageNamesGroup: [UIImage(named:"welcome_1")!,UIImage(named:"welcome_2")!,UIImage(named:"welcome_3")!,UIImage(named:"welcome_4")!,UIImage(named:"welcome_5")!, UIImage(named:"welcome_6")!])
        scrollView.addSubview(sdView)
    }
 
    @IBAction func skipLoginAction(_ sender: AnyObject) {
        if fromMenu {
            self.dismiss(animated: true, completion: nil)
        }else{
            self.present(makeStandardUINavigationController(MenuViewController()), animated: true, completion: nil)
        }
        
    }
    @IBAction func buttonActionManager(_ sender: AnyObject) {
        if loginB.isEqual(sender) {
            let login:LoginViewController = LoginViewController()
            self.navigationController?.pushViewController(login, animated: true)
            DTUserDefaults.presentMenu = true
        }

        if registB.isEqual(sender) {
            let register:RegisterViewController = RegisterViewController()
            self.navigationController?.pushViewController(register, animated: true)
        }
        
        if forgetButton.isEqual(sender) {
            let checkEmail:UINavigationController = UINavigationController(rootViewController: CheckEmailController())
            checkEmail.isNavigationBarHidden = true
            self.present(checkEmail, animated: true, completion: nil)
        }
    } 
}
