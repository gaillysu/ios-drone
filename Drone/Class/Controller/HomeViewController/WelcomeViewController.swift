//
//  HomeViewController.swift
//  Drone
//
//  Created by leiyuncun on 16/4/13.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit
import SnapKit

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

        
        let imageHeight:CGFloat = scrollView.frame.size.height
        let imageWidth:CGFloat = scrollView.bounds.size.width
        let scrollImage:UIScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
        scrollImage.isPagingEnabled = true;
        scrollView.addSubview(scrollImage)
        scrollImage.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(scrollView.snp.left)
            make.right.equalTo(scrollView.snp.right)
            make.top.equalTo(scrollView.snp.top)
            make.bottom.equalTo(scrollView.snp.bottom)
        }
        
        
    }

    override func viewDidLayoutSubviews() {
        let imageName:[String] = ["welcome_1","welcome_2","welcome_3","welcome_4","welcome_5","welcome_6"]
        
        var imageResources:[UIImage] = []
        for name in imageName {
            let imagePath:String = Bundle.main.path(forResource: name, ofType: "png")!
            if let imageValue = UIImage(contentsOfFile: imagePath) {
                imageResources.append(imageValue)
            }
        }
        
        let imageHeight:CGFloat = scrollView.frame.size.height
        let imageWidth:CGFloat = scrollView.bounds.size.width
        
        var scrollImage:UIScrollView?
        for view in scrollView.subviews {
            if view is UIScrollView {
                scrollImage = view as? UIScrollView
                for imageView in view.subviews {
                    if imageView is UIImageView {
                        (imageView as! UIImageView).image = nil
                        imageView.removeFromSuperview()
                    }
                }
            }
        }
        
        scrollImage?.contentSize = CGSize(width: imageWidth*CGFloat(imageResources.count), height: imageHeight)
        for (index,image) in imageResources.enumerated() {
            let imageView:UIImageView = UIImageView(image: image)
            imageView.frame = CGRect(x: scrollView.bounds.size.width*CGFloat(index), y: 0, width: imageWidth, height: imageHeight)
            imageView.contentMode = UIViewContentMode.scaleAspectFit
            scrollImage?.addSubview(imageView)
        }
    }
 
    @IBAction func skipLoginAction(_ sender: AnyObject) {
        if fromMenu {
            self.dismiss(animated: true, completion: nil)
        }else{
            if UserDevice.getAll().isEmpty {
                self.present(makeStandardUINavigationController(WhichDeviceViewController(toMenu: false)), animated: true, completion: nil)
            }else{
                self.present(makeStandardUINavigationController(MenuViewController()), animated: true, completion: nil)
            }
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
