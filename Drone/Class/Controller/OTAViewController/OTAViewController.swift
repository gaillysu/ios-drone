//
//  OTAViewController.swift
//  Drone
//
//  Created by Karl-John Chow on 7/7/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import iOSDFULibrary
import SwiftEventBus
class OTAViewController: UIViewController {
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    let otaViewModel = OTAViewModel()
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startButton.rx.tap.subscribe({ _ in
            self.startButton.enable(bool: false)
            self.navigationItem.hidesBackButton = true
            self.otaViewModel
                .statusObservable
                .map({ state -> String in
                    if state == DFUState.completed || state == DFUState.aborted {
                        self.navigationItem.hidesBackButton = false
                        AppDelegate.getAppDelegate().setAppConfig()
                    }
                return state.description()
                })
                .bind(to: self.statusLabel.rx.text)
                .addDisposableTo(self.disposeBag)
            self.otaViewModel.startDfu()
        }).addDisposableTo(disposeBag)
        
        self.versionLabel.text = otaViewModel.versionStatusString
        
        otaViewModel.uploadProcessObservable.subscribe { event in
            if let progress = event.element{
                self.progressView.setProgress(Float(progress)/100.0, animated: true)
            }
        }.addDisposableTo(disposeBag)
    }
    
    func closeButtonAction(){
        self.dismiss(animated: true, completion: nil)
    }
}
