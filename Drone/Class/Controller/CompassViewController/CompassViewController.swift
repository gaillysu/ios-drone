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
import RxDataSources
import RealmSwift

class CompassViewController: BaseViewController {
    
    @IBOutlet weak var compassTableView: UITableView!
    @IBOutlet weak var compassSwitch: UISwitch!
    let identifier = "CompassTableViewCell"
    let pickerView = UIPickerView()
    let realm = try! Realm()
    
    var disposeBag = DisposeBag()
    var autoOnValues:[Int] = [15, 30, 45, 60, 90, 120, 150, 180, 210, 240]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        compassTableView.register(UINib(nibName: "CompassTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: identifier)
        compassTableView.separatorStyle = .none
        
        let section = Variable([CompassSectionModel(header:"Compass Settings",footer:"",items:[CompassSectionModelItem(label: "Turn off auto motion detection")])])
        
        let dataSource = RxTableViewSectionedReloadDataSource<CompassSectionModel>()
        dataSource.configureCell = { (dataSource, table, indexPath, _) in
            if let cell = table.dequeueReusableCell(withIdentifier: self.identifier, for: indexPath) as? CompassTableViewCell{
                let item = dataSource[indexPath]
                cell.descriptionLabel.text = item.label
                if indexPath.row == 0 {
                    if let obj = Compass.getAll().first, let compass = obj as? Compass{
                        cell.valueTextField.text = compass.activeTime.timeRepresentable()
                        cell.valueTextField.inputView = self.pickerView
                    }
                }
                if (section.value.count - 1) == indexPath.row{
                    cell.seperatorview.isHidden = true
                }
                return cell
            }
            return UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: nil)
        }
        
        dataSource.titleForHeaderInSection = { dataSource, index in
            let section = dataSource[index]
            return section.header
        }
        
        section.asObservable()
            .bind(to: compassTableView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)
        
        compassTableView.rx.modelSelected(Drone.CompassSectionModelItem.self).subscribe { _ in
            if let indexPath = self.compassTableView.indexPathForSelectedRow{
                if indexPath.row == 0 {
                    if let cell = self.compassTableView.cellForRow(at: indexPath) as? CompassTableViewCell{
                        cell.valueTextField.becomeFirstResponder()
                    }
                }
                self.compassTableView.deselectRow(at: indexPath, animated: true)
            }
            }.addDisposableTo(disposeBag)
        
        self.compassSwitch.isOn = DTUserDefaults.compassState
        self.compassSwitch.rx.controlEvent(UIControlEvents.valueChanged).subscribe { event in
            DTUserDefaults.compassState = self.compassSwitch.isOn
            self.getAppDelegate().setAppConfig()
            }.addDisposableTo(disposeBag)
        
        self.addCloseButton(#selector(dismissViewController))
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
