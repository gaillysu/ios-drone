//
//  RegisterController.swift
//  Nevo
//
//  Created by Karl-John on 31/12/2015.
//  Copyright © 2015 Nevo. All rights reserved.
//

import UIKit
import GSMessages

class RegisterController: BaseViewController {
    @IBOutlet weak var backB: UIButton!
    @IBOutlet weak var nextB: UIButton!
    @IBOutlet weak var emailT: UITextField!
    @IBOutlet weak var passwordT: UITextField!
    @IBOutlet weak var registerL: UILabel!
    @IBOutlet weak var googleB: UIButton!
    @IBOutlet weak var facebookB: UIButton!
    @IBOutlet weak var twitterB: UIButton!

    init() {
        super.init(nibName: "RegisterController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func buttonActionManager(sender: AnyObject) {

        if backB.isEqual(sender) {
            self.navigationController?.popViewControllerAnimated(true)
        }

        if nextB.isEqual(sender) {
            let profile:ProfileViewController = ProfileViewController()
            self.navigationController?.pushViewController(profile, animated: true)
        }

        if googleB.isEqual(sender) {

        }

        if facebookB.isEqual(sender) {

        }

        if twitterB.isEqual(sender) {

        }
    }
    
}
