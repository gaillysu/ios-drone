//
//  AddPresetViewController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/3.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class AddGoalViewController: BaseViewController,ButtonManagerCallBack {

    @IBOutlet weak var addGoalView: AddGoalView!
    var addDelegate:AddGoalDelegate?
    
    init() {
        super.init(nibName: "AddGoalViewController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addGoalView.bulidAddGoalView(self.navigationItem, delegate: self)
        
    } 

    // MARK: - ButtonManagerDelegate
    func controllManager(sender:AnyObject){
        let number:NSString = addGoalView.goalNumber.text! as NSString
        let length:Int = number.length
        if(length >= 4){
            addDelegate?.onAddGoalNumber(Int(addGoalView.goalNumber.text!)!, name: addGoalView.goalName.text!)
            self.navigationController?.popViewControllerAnimated(true)
        }else{
            let aler:UIAlertView = UIAlertView(title: "", message: NSLocalizedString("Preset Number can't be empty, or you set less than four digits", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("Cancel", comment: ""))
            aler.show()
        }
    }

}
