//
//  OTAViewController.swift
//  Drone
//
//  Created by Karl-John Chow on 7/7/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import UIKit
import RxSwift
import iOSDFULibrary

class OTAViewController: UIViewController {

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!

    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startButton.rx.tap.subscribe({ _ in
            
        }).addDisposableTo(disposeBag)
    }
}
