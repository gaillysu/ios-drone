//
//  HomeViewController.swift
//  Drone
//
//  Created by leiyuncun on 16/4/13.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit
import RxSwift

class WelcomeViewController: BaseViewController {
    
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var scrollView: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var forgetPasswordButton: UIButton!
    @IBOutlet weak var skipLoginButton: UIButton!
    
    let scrollImage:UIScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 359))
    
    var fromMenu = false
    
    var disposeBag = DisposeBag()
    
    init(fromMenu: Bool = false) {
        super.init(nibName: "WelcomeViewController", bundle: Bundle.main)
        self.fromMenu = fromMenu
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.addSubview(scrollImage)
        setupRxSwift()
        
    }
    
    override func viewDidLayoutSubviews() {
        
        let imageName:[String] = ["welcome_1","welcome_2"]
        var imageResources:[UIImage] = []
        imageName.forEach { name in
            let imagePath:String = Bundle.main.path(forResource: name, ofType: "png")!
            if let imageValue = UIImage(contentsOfFile: imagePath) {
                imageResources.append(imageValue)
            }
        }
        
        let imageHeight:CGFloat = scrollView.frame.size.height
        let imageWidth:CGFloat = UIScreen.main.bounds.size.width
        
        scrollImage.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: imageHeight)
        scrollImage.contentSize = CGSize(width: imageWidth*CGFloat(imageResources.count), height: imageHeight)
        scrollImage.isPagingEnabled = true;
        
        scrollImage.subviews.forEach { view in
            if view is UIImageView {
                (view as! UIImageView).image = nil
                view.removeFromSuperview()
            }
        }
        
        imageResources.enumerated().forEach { (index, image) in
            let imageView:UIImageView = UIImageView(image: image)
            imageView.frame = CGRect(x: imageWidth*CGFloat(index), y: 0, width: imageWidth , height: imageHeight)
            imageView.contentMode = UIViewContentMode.scaleAspectFit
            scrollImage.addSubview(imageView)
        }
    }
    
    func setupRxSwift(){
        loginButton.rx.tap.subscribe { _ in
            let login:LoginViewController = LoginViewController()
            self.navigationController?.pushViewController(login, animated: true)
            DTUserDefaults.presentMenu = true
            }.addDisposableTo(disposeBag)
        
        registerButton.rx.tap.subscribe { _ in
            let register:RegisterViewController = RegisterViewController()
            self.navigationController?.pushViewController(register, animated: true)
            }.addDisposableTo(disposeBag)
        
        forgetPasswordButton.rx.tap.subscribe { _ in
            let checkEmail:UINavigationController = UINavigationController(rootViewController: CheckEmailController())
            checkEmail.isNavigationBarHidden = true
            self.present(checkEmail, animated: true, completion: nil)
            }.addDisposableTo(disposeBag)
        
        skipLoginButton.rx.tap.subscribe { _ in
            if self.fromMenu {
                self.dismiss(animated: true, completion: nil)
            }else{
                if UserDevice.getAll().isEmpty {
                    self.present(self.makeStandardUINavigationController(WhichDeviceViewController(toMenu: false)), animated: true, completion: nil)
                }else{
                    self.present(self.makeStandardUINavigationController(MenuViewController()), animated: true, completion: nil)
                }
            }
            }.addDisposableTo(disposeBag)
    }
}
