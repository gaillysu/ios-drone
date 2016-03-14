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

class ProfileViewController: BaseViewController, SMSegmentViewDelegate {


    @IBOutlet weak var ageTextField: AkiraTextField!
    @IBOutlet weak var lengthTextField: AkiraTextField!
    @IBOutlet weak var firstNameTextField: AkiraTextField!
    @IBOutlet weak var lastNameTextField: AkiraTextField!
    @IBOutlet weak var sexSegment: UIView!
    @IBOutlet weak var metricsSegment: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let segmentProperties = ["OnSelectionBackgroundColour": UIColor.whiteColor(),"OffSelectionBackgroundColour": AppTheme.BASE_COLOR(),"OnSelectionTextColour": AppTheme.BASE_COLOR(),"OffSelectionTextColour": UIColor.whiteColor()]
        let sexSegmentView = SMSegmentView(frame: CGRect(x: 2, y: 2, width: sexSegment.frame.size.width - 4, height: sexSegment.frame.size.height - 4), separatorColour: UIColor.whiteColor(), separatorWidth: 2, segmentProperties: segmentProperties)
        sexSegmentView.addSegmentWithTitle("Male", onSelectionImage: nil, offSelectionImage: nil)
        sexSegmentView.addSegmentWithTitle("Female", onSelectionImage: nil, offSelectionImage: nil)
        let metricsSegmentView = SMSegmentView(frame: CGRect(x: 2, y: 2, width: metricsSegment.frame.size.width - 4, height: metricsSegment.frame.size.height - 4), separatorColour: UIColor.whiteColor(), separatorWidth: 2, segmentProperties: segmentProperties)
        metricsSegmentView.addSegmentWithTitle("Metrics", onSelectionImage: nil, offSelectionImage: nil)
        metricsSegmentView.addSegmentWithTitle("Imperical", onSelectionImage: nil, offSelectionImage: nil)
        metricsSegment.addSubview(metricsSegmentView)
        metricsSegmentView.delegate = self
        sexSegment.addSubview(sexSegmentView)
        sexSegmentView.delegate = self
    }
 
    init() {
        super.init(nibName: "ProfileViewController", bundle: NSBundle.mainBundle())
    }
    
    @IBAction func saveButtonAction(sender: AnyObject) {
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func segmentView(segmentView: SMBasicSegmentView, didSelectSegmentAtIndex index: Int) {
        
    }
}