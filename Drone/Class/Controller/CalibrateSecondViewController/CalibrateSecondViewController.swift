//
//  CalibrateSecondViewController.swift
//  Drone
//
//  Created by Karl-John Chow on 19/4/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CalibrateSecondViewController: BaseViewController {
    @IBOutlet weak var counterClockwiseButton: CounterClockwiseButton!
    @IBOutlet weak var clockwiseButton: ClockwiseButton!
    @IBOutlet weak var finishButton: UIButton!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Calibrate"
        
        finishButton.rx.controlEvent(UIControlEvents.touchUpInside).subscribe { _ in
            self.getAppDelegate().stopCalibrateHands()
            if DTUserDefaults.presentMenu{
                self.present(self.makeStandardUINavigationController(MenuViewController()), animated: true, completion: nil)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
            }.addDisposableTo(disposeBag)
        counterClockwiseButton.rx.controlEvent(UIControlEvents.touchUpInside).subscribe { _ in
            self.getAppDelegate().calibrateHands(operation: .secondReverseOneStep)
            }.addDisposableTo(disposeBag)
        clockwiseButton.rx.controlEvent(UIControlEvents.touchUpInside).subscribe { _ in
            self.getAppDelegate().calibrateHands(operation: .secondAdvanceOneStep)
            }.addDisposableTo(disposeBag)
        clockwiseButton.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressClockwise)))
        counterClockwiseButton.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressCounterClockwise)))
    }

    func longPressClockwise(gesture:UILongPressGestureRecognizer){
        switch gesture.state {
        case .began:
            self.getAppDelegate().calibrateHands(operation: .secondStartAC)
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
            self.getAppDelegate().calibrateHands(operation: .secondStartRC)
        case .cancelled:
            self.getAppDelegate().calibrateHands(operation: .stopHandsMovement)
        case .ended:
            self.getAppDelegate().calibrateHands(operation: .stopHandsMovement)
        default: break
        }
    }
}
