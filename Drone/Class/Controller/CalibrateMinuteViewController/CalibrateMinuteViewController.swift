//
//  CalibrateMinuteViewController.swift
//  Drone
//
//  Created by Karl-John Chow on 19/4/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CalibrateMinuteViewController: BaseViewController {
    
    @IBOutlet weak var counterClockwiseButton: CounterClockwiseButton!
    @IBOutlet weak var clockwiseButton: ClockwiseButton!
    @IBOutlet weak var nextButton: UIButton!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Calibrate"
        
        nextButton.rx.controlEvent(UIControlEvents.touchUpInside).subscribe { _ in
            self.navigationController?.pushViewController(CalibrateSecondViewController(), animated: true)
            }.addDisposableTo(disposeBag)
        
        counterClockwiseButton.rx.controlEvent(UIControlEvents.touchUpInside).subscribe { _ in
            self.getAppDelegate().calibrateHands(operation: .minuteReverseOneStep)
            }.addDisposableTo(disposeBag)
        
        clockwiseButton.rx.controlEvent(UIControlEvents.touchUpInside).subscribe { _ in
            self.getAppDelegate().calibrateHands(operation: .minuteAdvanceOneStep)
            }.addDisposableTo(disposeBag)
        clockwiseButton.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressClockwise)))
        counterClockwiseButton.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressCounterClockwise)))
    }
    
    func longPressClockwise(gesture:UILongPressGestureRecognizer){
        switch gesture.state {
        case .began:
            self.getAppDelegate().calibrateHands(operation: .minuteStartAC)
        case .cancelled:
            self.getAppDelegate().calibrateHands(operation: .stopHandsMovement)
        case .ended:
            self.getAppDelegate().calibrateHands(operation: .stopHandsMovement)
        default: break
        }
    }
    
    func longPressCounterClockwise(gesture:UILongPressGestureRecognizer){
        switch gesture.state {
        case .began:
            self.getAppDelegate().calibrateHands(operation: .minuteStartRC)
        case .cancelled:
            self.getAppDelegate().calibrateHands(operation: .stopHandsMovement)
        case .ended:
            self.getAppDelegate().calibrateHands(operation: .stopHandsMovement)
        default: break
        }
    }
    
}
