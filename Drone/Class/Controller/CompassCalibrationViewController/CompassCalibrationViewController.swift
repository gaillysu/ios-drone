//
//  CompassCalibrationViewController.swift
//  Drone
//
//  Created by Karl-John Chow on 23/5/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import UIKit
import RxSwift

class CompassCalibrationViewController: UIViewController {

    @IBOutlet weak var finishButton: UIButton!
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Calibrate"
        self.navigationItem.setHidesBackButton(true, animated: false)
        getAppDelegate().startCompassCalibration()
        finishButton.rx.tap.subscribe({ _ in
            self.getAppDelegate().stopCompassCalibration()
            self.dismiss(animated: true, completion: nil)
        }).addDisposableTo(disposeBag)
    }
}
