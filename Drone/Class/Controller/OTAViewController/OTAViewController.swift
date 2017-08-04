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
        title = "OTA"
        startButton.rx.tap.subscribe({ _ in
            self.startButton.enable(bool: false)
            self.navigationItem.hidesBackButton = true
            
            self.otaViewModel
                .statusObservable
                .map({ state -> String in
                    if state.status == DFUState.completed.rawValue || state.status == DFUState.aborted.rawValue {
                        self.navigationItem.hidesBackButton = false
                        AppDelegate.getAppDelegate().setAppConfig()
                    }else if state.status == -1 {
                        self.navigationItem.hidesBackButton = false
                        self.startButton.setTitle("Try again", for: .normal)
                        self.startButton.enable(bool: true)
                    }else if state.status == -2 {
                        self.showNoInternetDialog()
                        self.startButton.enable(bool: true)
                    }
                    return state.message
                })
                .bind(to: self.statusLabel.rx.text)
                .addDisposableTo(self.disposeBag)
            self.otaViewModel.startDfu()
        }).addDisposableTo(disposeBag)
        
        otaViewModel
            .versionStatusString
            .bind(to: versionLabel.rx.text)
            .addDisposableTo(disposeBag)
        
        otaViewModel
            .uploadProcessObservable
            .subscribe(onNext: { self.progressView.setProgress(Float($0)/100.0, animated: true) })
            .addDisposableTo(disposeBag)
    }
    
    func closeButtonAction(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func showNoInternetDialog(){
        let alertView = UIAlertController(title: "No network connection", message: "Cannot get the newest firmware. Would you like to use the local firmware to do OTA?", preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            self.checkLocalDFU()
        }))
        alertView.addAction(UIAlertAction(title: "No", style: .cancel, handler: { _ in
            self.navigationItem.hidesBackButton = false
            self.startButton.titleLabel?.text = "Start"
            self.startButton.enable(bool: true)
        }))
        self.present(alertView, animated: true, completion: nil)
        
    }
    
    func checkLocalDFU(){
        guard let url = AppTheme.GET_FIRMWARE_FILES("DFUFirmware").first else{
            fatalError("Could not open Firmware file for some reason")
        }
        let firmwareVersion = AppTheme.firmwareVersionFrom(path: url)
        let currentVersion = DTUserDefaults.lastKnownWatchVersion
        
        if firmwareVersion >= currentVersion{
            let alertView = UIAlertController(title: "Newest Version", message: "You already got the newest or a newer version, do you wish to proceed?", preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                self.otaViewModel.startDfu()
            }))
            alertView.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            self.present(alertView, animated: true, completion: nil)
        }else{
            self.otaViewModel.startDfu()
        }
    }
    
}
