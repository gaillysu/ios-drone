//
//  AddInstructionHeader.swift
//  Drone
//
//  Created by Karl Chow on 8/30/16.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation

class AddInstructionHeader: UIView {

    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var amountOfSensorLabel: UILabel!
    
    @IBOutlet var startRecordingButton: UIButton!
    @IBOutlet var stopRecordingButton: UIButton!

    override func awakeFromNib() {
        startRecordingButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Disabled)
        stopRecordingButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Disabled)
    }
    
    func addActionToButton (target:AnyObject,startRecordingSelector:Selector, stopRecordingSelector: Selector ) {
        startRecordingButton.addTarget(target, action: startRecordingSelector, forControlEvents: UIControlEvents.TouchUpInside)
        stopRecordingButton.addTarget(target, action: stopRecordingSelector, forControlEvents: UIControlEvents.TouchUpInside)
        stopRecordingButton.enabled = false
    }
    
    func startRecordToggle(){
        startRecordingButton.enabled = false
        stopRecordingButton.enabled = true
        statusLabel.text = "Started Recording"
    }
    
    func stopRecordToggle(){
        startRecordingButton.enabled = true
        stopRecordingButton.enabled = false
        statusLabel.text = "Finished Recording"
        startRecordingButton.setTitle("Record again", forState: UIControlState.Normal)
    }
}