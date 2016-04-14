//
//  ProfileController.swift
//  Nevo
//
//  Created by leiyuncun on 16/3/2.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import TextFieldEffects
import SMSegmentView


class ProfileViewController: BaseViewController,SMSegmentViewDelegate {

    @IBOutlet weak var ageTextField: AkiraTextField!
    @IBOutlet weak var lengthTextField: AkiraTextField!
    @IBOutlet weak var weightTextField: AkiraTextField!
    @IBOutlet weak var stridelengthTextField: AkiraTextField!
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

    }

    override func viewDidLayoutSubviews() {
        if(segmentView == nil) {
            let segmentProperties = ["OnSelectionBackgroundColour": UIColor.whiteColor(),"OffSelectionBackgroundColour": AppTheme.BASE_COLOR(),"OnSelectionTextColour": AppTheme.BASE_COLOR(),"OffSelectionTextColour": UIColor.whiteColor()]

            let segmentFrame = CGRect(x: 0, y: 0, width: metricsSegment.frame.size.width, height: metricsSegment.frame.size.height)
            segmentView = SMSegmentView(frame: segmentFrame, separatorColour: UIColor(white: 0.95, alpha: 0.3), separatorWidth: 0.5, segmentProperties: segmentProperties)

            segmentView!.delegate = self

            segmentView!.backgroundColor = UIColor.clearColor()

            segmentView!.layer.cornerRadius = 5.0
            segmentView!.layer.borderColor = UIColor(white: 0.85, alpha: 1.0).CGColor
            segmentView!.layer.borderWidth = 1.0

            // Add segments
            segmentView!.addSegmentWithTitle("Male", onSelectionImage: nil, offSelectionImage: nil)
            segmentView!.addSegmentWithTitle("Female", onSelectionImage: nil, offSelectionImage: nil)
            
            metricsSegment.addSubview(segmentView!)
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