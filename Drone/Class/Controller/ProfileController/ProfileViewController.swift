//
//  ProfileController.swift
//  Nevo
//
//  Created by leiyuncun on 16/3/2.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import AutocompleteField
import SMSegmentView
import UIColor_Hex_Swift


class ProfileViewController: BaseViewController,SMSegmentViewDelegate {

    @IBOutlet weak var backB: UIButton!
    @IBOutlet weak var nextB: UIButton!
    @IBOutlet weak var textfiledBG: UIView!
    @IBOutlet weak var ageTextField: AutocompleteField!
    @IBOutlet weak var lengthTextField: AutocompleteField!
    @IBOutlet weak var weightTextField: AutocompleteField!
    @IBOutlet weak var stridelengthTextField: AutocompleteField!
    @IBOutlet weak var metricsSegment: UIView!

    var segmentView:SMSegmentView?

    init() {
        super.init(nibName: "ProfileViewController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        textfiledBG.layer.borderColor = UIColor(rgba: "#6F7179").CGColor
    }

    override func viewDidLayoutSubviews() {
        if(segmentView == nil) {
            let segmentProperties = ["OnSelectionBackgroundColour": UIColor(rgba: "#66cccc"),"OffSelectionBackgroundColour": UIColor.whiteColor(),"OnSelectionTextColour": UIColor.whiteColor(),"OffSelectionTextColour": UIColor(rgba: "#95989a")]

            let segmentFrame = CGRect(x: 0, y: 0, width: metricsSegment.frame.size.width, height: metricsSegment.frame.size.height)
            segmentView = SMSegmentView(frame: segmentFrame, separatorColour: UIColor(white: 0.95, alpha: 0.3), separatorWidth: 1.0, segmentProperties: segmentProperties)

            segmentView!.delegate = self
            segmentView!.layer.borderColor = UIColor(white: 0.85, alpha: 1.0).CGColor
            segmentView!.layer.borderWidth = 1.0

            // Add segments
            segmentView!.addSegmentWithTitle("Male", onSelectionImage: nil, offSelectionImage: nil)
            segmentView!.addSegmentWithTitle("Female", onSelectionImage: nil, offSelectionImage: nil)
            
            metricsSegment.addSubview(segmentView!)
        }
    }

    @IBAction func buttonActionManager(sender: AnyObject) {
        if (backB.isEqual(sender)) {
            self.navigationController?.popViewControllerAnimated(true)
        }

        if (nextB.isEqual(sender)) {
            let maintabbar:YouDeviceViewController = YouDeviceViewController()
            self.navigationController?.pushViewController(maintabbar, animated: true)
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        ageTextField.resignFirstResponder()
        lengthTextField.resignFirstResponder()
        weightTextField.resignFirstResponder()
        stridelengthTextField.resignFirstResponder()
    }

    func segmentView(segmentView: SMBasicSegmentView, didSelectSegmentAtIndex index: Int) {
        debugPrint("Select segment at index: \(index)")
    }
}