//
//  CompassViewController.swift
//  Drone
//
//  Created by Karl-John Chow on 18/4/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import UIKit
import Foundation
import RxSwift
import RxCocoa
import RealmSwift

class CompassViewController: BaseViewController {
    
    @IBOutlet weak var compassTableView: UITableView!
    @IBOutlet weak var compassSwitch: UISwitch!
    let identifier = "CompassTableViewCell"
    let pickerView = UIPickerView()
    let realm = try! Realm()
    
    var disposeBag = DisposeBag()
    var items:Variable<[String]> = Variable(["Auto turn off motion detection"])
    var autoOnValues:[Int] = [15, 30, 45, 60, 90, 120, 150, 180, 210, 240]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        compassTableView.register(UINib(nibName: "CompassTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: identifier)
        compassTableView.separatorStyle = .none
        self.compassSwitch.isOn = DTUserDefaults.compassState
        self.compassSwitch.rx.controlEvent(UIControlEvents.valueChanged).subscribe { event in
            DTUserDefaults.compassState = self.compassSwitch.isOn
            self.getAppDelegate().setAppConfig()
            }.addDisposableTo(disposeBag)
        
        self.addCloseButton(#selector(dismissViewController))
        items.asObservable().bind(to: compassTableView.rx
            .items(cellIdentifier: identifier, cellType: CompassTableViewCell.self)){
                row, item, cell in
                cell.descriptionLabel.text = item
                if row == 0{
                    if let obj = Compass.getAll().first, let compass = obj as? Compass{
                        cell.valueTextField.text = compass.activeTime.timeRepresentable()
                        cell.valueTextField.inputView = self.pickerView
                    }
                }
                
                if (self.items.value.count - 1) == row{
                    cell.seperatorview.isHidden = true
                }
            }.addDisposableTo(disposeBag)
        
        compassTableView.rx.modelSelected(String.self).subscribe { _ in
            if let indexPath = self.compassTableView.indexPathForSelectedRow{
                if indexPath.row == 0 {
                    if let cell = self.compassTableView.cellForRow(at: indexPath) as? CompassTableViewCell{
                        cell.valueTextField.becomeFirstResponder()
                    }
                }
                self.compassTableView.deselectRow(at: indexPath, animated: true)
            }
            }.addDisposableTo(disposeBag)
    }
    
    func dismissViewController(){
        self.dismiss(animated: true, completion: nil)
    }
}

extension CompassViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let cell = self.compassTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? CompassTableViewCell{
            try! realm.write {
                if let obj = Compass.getAll().first, let compass = obj as? Compass{
                    compass.activeTime = self.autoOnValues[row]
                    getAppDelegate().setCompassAutoMinutes()
                }
            }
            cell.valueTextField.text = self.autoOnValues[row].timeRepresentable()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.autoOnValues[row].longTimeRepresentable()
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return autoOnValues.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}
