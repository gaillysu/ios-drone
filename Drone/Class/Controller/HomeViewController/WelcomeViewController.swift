//
//  HomeViewController.swift
//  Drone
//
//  Created by leiyuncun on 16/4/13.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit
import SDCycleScrollView

class WelcomeViewController: UIViewController {

    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var scrollView: UIView!
    @IBOutlet weak var loginB: UIButton!
    @IBOutlet weak var registB: UIButton!


    init() {
        super.init(nibName: "HomeViewController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        headerImage.contentMode = UIViewContentMode.ScaleAspectFit;
        
        loginB.layer.borderWidth = 1
        loginB.layer.borderColor = UIColor(red: 111.0/225.0, green: 113.0/255.0, blue: 121.0/255.0, alpha: 1).CGColor

        registB.layer.borderWidth = 1
        registB.layer.borderColor = UIColor(red: 111.0/225.0, green: 113.0/255.0, blue: 121.0/255.0, alpha: 1).CGColor

        // Do any additional setup after loading the view.
    }

    override func viewDidLayoutSubviews() {
        let sdView:SDCycleScrollView = SDCycleScrollView(frame: CGRectMake(0, 0, scrollView.bounds.size.width, scrollView.frame.size.height), shouldInfiniteLoop: true, imageNamesGroup: [AppTheme.GET_RESOURCES_IMAGE("drone1"),AppTheme.GET_RESOURCES_IMAGE("drone2"),AppTheme.GET_RESOURCES_IMAGE("drone3")])
        scrollView.addSubview(sdView)
    }


    @IBAction func buttonActionManager(sender: AnyObject) {
        if loginB.isEqual(sender) {
            let logoin:LoginController = LoginController()
            self.navigationController?.pushViewController(logoin, animated: true)
        }

        if registB.isEqual(sender) {
            let register:RegisterController = RegisterController()
            self.navigationController?.pushViewController(register, animated: true)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
