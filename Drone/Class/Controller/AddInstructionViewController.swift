//
//  AddInstructionViewController.swift
//  Drone
//
//  Created by Karl-John on 29/8/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import UIKit

class AddInstructionViewController: BaseViewController {

    @IBOutlet var tableview: UITableView!
    
    var header:AddInstructionHeader?;
    
    var timer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Add Instruction"
        self.addCloseButton(#selector(close))
        header = UIView.loadFromNibNamed("AddInstructionHeader") as? AddInstructionHeader
        
        header!.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, header!.frame.height)
        let headerView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, header!.frame.height))
        headerView.addSubview(header!)
        tableview.tableHeaderView = headerView
        header?.addActionToButton(self,startRecordingSelector: #selector(self.startRecording), stopRecordingSelector: #selector(self.stopRecording))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func close() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func startRecording() {
        print("Heh?");
        header!.startRecordToggle()
        timer.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(timerSecondTriggeredAction), userInfo: nil, repeats: true)
    }
    
    func stopRecording() {
        print("lol??");
        header!.stopRecordToggle()
        timer.invalidate()
    }
    
    func timerSecondTriggeredAction(){
        print("Okidoki");
    }
}
