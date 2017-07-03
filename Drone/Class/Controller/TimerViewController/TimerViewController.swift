//
//  TimerViewController.swift
//  Drone
//
//  Created by Karl-John Chow on 29/6/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TimerViewController: UIViewController {

    @IBOutlet weak var timerPicker: UIDatePicker!
    @IBOutlet weak var pickerTableView: UITableView!
    
    let data = Observable<[String]>.just(["Sync Timer", "Reset Timer"])

    let disposeBag = DisposeBag()
    let identifier = "UITableViewCell"
    
    let timerViewModel = TimerViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timerPicker.backgroundColor = .getLightBaseColor()
        timerPicker.setValue(UIColor.white, forKey: "textColor")
        timerPicker.countDownDuration = TimeInterval(timerViewModel.countdownTime)
        pickerTableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        let countDownTime = timerViewModel.countdownTime
        if countDownTime < 1439{
            self.timerPicker.setDate(Calendar.current.date(bySettingHour: Int(countDownTime/60), minute: countDownTime%60, second: 0, of: Date())!, animated: true)
        }else{
            timerViewModel.countdownTime = 1
            self.timerPicker.setDate(Calendar.current.date(bySettingHour: 0, minute: 1, second: 0, of: Date())!, animated: true)
        }
        self.timerViewModel.countdownTime = timerViewModel.countdownTime
        
        data.bind(to: pickerTableView.rx.items(cellIdentifier: identifier)) { index, model, cell in
            cell.textLabel?.text = model
            cell.backgroundColor = .getBaseColor()
            cell.textLabel?.textColor = .white
            }.disposed(by: disposeBag)
        
        pickerTableView.rx.itemSelected.subscribe ({ event in
            guard let indexPath = event.element else {
                fatalError("Lol")
            }
            self.pickerTableView.deselectRow(at: indexPath, animated: true)
            switch indexPath.row{
            case 0:
                self.timerViewModel.countdownTime = Int(self.timerPicker.countDownDuration/60)
                self.timerViewModel.syncCountDownTimer()
            case 1:
                self.timerPicker.setDate(Calendar.current.date(bySettingHour: 0, minute: 1, second: 0, of: Date())!, animated: true)
                self.timerViewModel.countdownTime = 1
            default: break
            }
        }).addDisposableTo(disposeBag)
        
        self.timerPicker.rx.countDownDuration.subscribe { event in
            guard let value = event.element else{
                fatalError("Lol")
            }
            self.timerViewModel.countdownTime = Int(value/60)
        }.addDisposableTo(disposeBag)
        
    }
    
}
