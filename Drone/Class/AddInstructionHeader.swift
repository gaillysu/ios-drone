//
//  AddInstructionHeader.swift
//  Drone
//
//  Created by Karl Chow on 8/30/16.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import IQKeyboardManagerSwift

class AddInstructionHeader: UIView {

    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var amountOfSensorLabel: UILabel!
    
    @IBOutlet var instructionNameEditTextField: UITextField!
    @IBOutlet var recordedTimeLabel: UILabel!
    
    @IBOutlet var startRecordingButton: UIButton!
    @IBOutlet var stopRecordingButton: UIButton!

    private var timer:NSTimer = NSTimer()
    private var amountDots:Int = 0
    
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
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(updateStatusLabel), userInfo: nil, repeats: true)
        statusLabel.text = "Recording"
    }
    
    func updateStatusLabel() {
        if (statusLabel.text?.componentsSeparatedByString(".").count == 3 ){
            statusLabel.text = "Recording"
        }else{
            statusLabel.text = statusLabel.text! + "."
        }
    }
    
    func stopRecordToggle(){
        startRecordingButton.enabled = true
        stopRecordingButton.enabled = false
        timer.invalidate()
        statusLabel.text = "Finished"
        startRecordingButton.setTitle("Record again", forState: UIControlState.Normal)
    }
}