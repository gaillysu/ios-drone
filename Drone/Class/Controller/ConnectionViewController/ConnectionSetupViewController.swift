//
//  ConnectionViewController.swift
//  Drone
//
//  Created by leiyuncun on 16/4/21.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit

class ConnectionSetupViewController: UIViewController {

    @IBOutlet weak var nextB: UIButton!
    init() {
        super.init(nibName: "ConnectionSetupViewController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func buttonActionManager(sender: AnyObject) {
        AppDelegate.getAppDelegate().rootTabbarController()
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
