//
//  CalibrateHourViewController.swift
//  Drone
//
//  Created by Karl-John Chow on 19/4/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CalibrateHourViewController: BaseViewController {

    @IBOutlet weak var clockwiseButton: UIButton!
    @IBOutlet weak var counterClockwiseButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Calibrate"
        self.navigationItem.setHidesBackButton(true, animated: false)
        getAppDelegate().startCalibrateHands()

        nextButton.rx.controlEvent(UIControlEvents.touchUpInside).subscribe { _ in
            self.navigationController?.pushViewController(CalibrateMinuteViewController(), animated: true)
        }.addDisposableTo(disposeBag)
        
        counterClockwiseButton.rx.controlEvent(UIControlEvents.touchUpInside).subscribe { _ in
            self.getAppDelegate().calibrateHands(operation: .hourReverseOneStep)
        }.addDisposableTo(disposeBag)
        
        clockwiseButton.rx.controlEvent(UIControlEvents.touchUpInside).subscribe { _ in
            self.getAppDelegate().calibrateHands(operation: .hourAdvanceOneStep)
        }.addDisposableTo(disposeBag)
        clockwiseButton.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressClockwise)))
        counterClockwiseButton.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressCounterClockwise)))
    }
    
    func longPressClockwise(gesture:UILongPressGestureRecognizer){
        switch gesture.state {
        case .began:
            self.getAppDelegate().calibrateHands(operation: .hourStartAC)
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
            self.getAppDelegate().calibrateHands(operation: .hourStartRC)
        case .cancelled:
            self.getAppDelegate().calibrateHands(operation: .stopHandsMovement)
        case .ended:
            self.getAppDelegate().calibrateHands(operation: .stopHandsMovement)
        default: break
        }
    }
}
