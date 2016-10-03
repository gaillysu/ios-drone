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
    @IBOutlet var resetDummyButton: UIButton!
    
    
    fileprivate var timer:Timer = Timer()
    fileprivate var amountDots:Int = 0
    
    override func awakeFromNib() {
        startRecordingButton.setTitleColor(UIColor.gray, for: UIControlState.disabled)
        stopRecordingButton.setTitleColor(UIColor.gray, for: UIControlState.disabled)
    }
    
    func addActionToButton (_ target:AnyObject,startRecordingSelector:Selector, stopRecordingSelector: Selector, resetDummySelector: Selector) {
        startRecordingButton.addTarget(target, action: startRecordingSelector, for: UIControlEvents.touchUpInside)
        stopRecordingButton.addTarget(target, action: stopRecordingSelector, for: UIControlEvents.touchUpInside)
        resetDummyButton.addTarget(target, action: resetDummySelector, for: UIControlEvents.touchUpInside)
        stopRecordingButton.isEnabled = false
    }
    
    func startRecordToggle(){
        startRecordingButton.isEnabled = false
        stopRecordingButton.isEnabled = true
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateStatusLabel), userInfo: nil, repeats: true)
        statusLabel.text = "Recording"
    }
    
    func updateStatusLabel() {
        if (statusLabel.text?.components(separatedBy: ".").count == 3 ){
            statusLabel.text = "Recording"
        }else{
            statusLabel.text = statusLabel.text! + "."
        }
    }
    
    func stopRecordToggle(){
        startRecordingButton.isEnabled = true
        stopRecordingButton.isEnabled = false
        timer.invalidate()
        statusLabel.text = "Finished"
        startRecordingButton.setTitle("Record again", for: UIControlState())
    }
}
