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
import BRYXBanner

class CompassViewController: BaseViewController {
    
    @IBOutlet weak var compassTableView: UITableView!
    @IBOutlet weak var compassSwitch: UISwitch!
    let identifier = "CompassTableViewCell"
    let pickerView = UIPickerView()
    let realm = try! Realm()
    
    var disposeBag = DisposeBag()
    let autoOnValues:[Int] = [15, 30, 45, 60, 90, 120, 150, 180, 210, 240] // minutes
    let screenTimeoutValues:[Int] = [15, 30, 45, 60, 90, 120] // seconds
    
    var activeValues:[Int]?
    var activeIndexPath:IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        compassTableView.register(UINib(nibName: identifier, bundle: Bundle.main), forCellReuseIdentifier: identifier)
        compassTableView.separatorStyle = .none
        
        let section = Variable([CompassSectionModel(header:"Compass Settings",footer:"",items:
            [CompassSectionModelItem(label: "Turn off auto motion detection"),
             CompassSectionModelItem(label: "Screen timeout"),
             CompassSectionModelItem(label: "Start Compass Calibration")
            ])])
        
        let dataSource = RxTableViewSectionedReloadDataSource<CompassSectionModel>()
        dataSource.configureCell = { (dataSource, table, indexPath, _) in
            let cell:CompassTableViewCell = table.dequeueReusableCell(forIndexPath: indexPath)
            let item = dataSource[indexPath]
            cell.descriptionLabel.text = item.label
            if let obj = Compass.getAll().first, let compass = obj as? Compass{
                switch indexPath.row {
                case 0:
                    cell.valueTextField.text = compass.autoMotionDetection.timeRepresentable()
                    cell.valueTextField.inputView = self.pickerView
                    cell.valueTextField.rx.controlEvent(UIControlEvents.editingDidBegin).subscribe({ _ in
                        self.activeValues = self.autoOnValues
                        self.activeIndexPath = indexPath
                    }).addDisposableTo(self.disposeBag)
                case 1:
                    cell.valueTextField.text = compass.screenTimeout.secondsRepresentable()
                    cell.valueTextField.inputView = self.pickerView
                    cell.valueTextField.rx.controlEvent(UIControlEvents.editingDidBegin).subscribe({ _ in
                        self.activeValues = self.screenTimeoutValues
                        self.activeIndexPath = indexPath
                    }).addDisposableTo(self.disposeBag)
                case 2:
                    cell.valueTextField.isHidden = true
                default:
                    break
                }
            }
            return cell
        }
        
        dataSource.titleForHeaderInSection = { dataSource, index in
            let section = dataSource[index]
            return section.header
        }
        
        section.asObservable()
            .bind(to: compassTableView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)
        
        compassTableView.rx.modelSelected(CompassSectionModelItem.self).subscribe { _ in
            if let indexPath = self.compassTableView.indexPathForSelectedRow{
                self.compassTableView.deselectRow(at: indexPath, animated: true)
                switch indexPath.row{
                case 0:
                    let cell:CompassTableViewCell = self.compassTableView.cellForRowAt(forIndexPath: indexPath)
                    cell.valueTextField.becomeFirstResponder()
                    self.activeValues = self.autoOnValues
                    self.activeIndexPath = indexPath
                case 1:
                    let cell:CompassTableViewCell = self.compassTableView.cellForRowAt(forIndexPath: indexPath)
                    cell.valueTextField.becomeFirstResponder()
                    self.activeValues = self.screenTimeoutValues
                    self.activeIndexPath = indexPath
                case 2:
                    if !(self.getAppDelegate().getMconnectionController()?.isConnected())!{
                        let banner = Banner(title: "Watch is disconnected, connect to calibrate.", subtitle: nil, image: nil, backgroundColor:UIColor.getBaseColor())
                        banner.dismissesOnTap = true
                        banner.show(duration: 1.2)
                    } else if !DTUserDefaults.compassEnabled {
                        let banner = Banner(title: "Compass is disabled, enable to calibrate.", subtitle: nil, image: nil, backgroundColor:UIColor.getBaseColor())
                        banner.dismissesOnTap = true
                        banner.show(duration: 1.2)
                    }else{
                        self.present(self.makeStandardUINavigationController(CompassCalibrationViewController()), animated: true, completion: nil)
                    }
                default: break
                }
            }
            }.addDisposableTo(disposeBag)
        self.compassSwitch.isOn = DTUserDefaults.compassEnabled
        
        self.compassSwitch.rx.controlEvent(UIControlEvents.valueChanged).subscribe { event in
            DTUserDefaults.compassEnabled = self.compassSwitch.isOn
            self.getAppDelegate().setCompass()
            }.addDisposableTo(disposeBag)
        self.addCloseButton(#selector(dismissViewController))
    }
    
    func dismissViewController(){
        self.dismiss(animated: true, completion: nil)
    }
}

extension CompassViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let indexPath = self.activeIndexPath, let values = self.activeValues else {
            fatalError("User Pressed but there is no indexPath/Values.")
        }
        guard let obj = Compass.getAll().first, let compass = obj as? Compass else {
            fatalError("Could not fetch compass but there should be no problem")
        }
        let cell:CompassTableViewCell = self.compassTableView.cellForRowAt(forIndexPath: indexPath)
        try! realm.write {
            switch indexPath.row{
            case 0:
                compass.autoMotionDetection = self.autoOnValues[row]
                getAppDelegate().setCompassAutoMotionDetection()
                cell.valueTextField.text = values[row].timeRepresentable()
            case 1:
                compass.screenTimeout = self.screenTimeoutValues[row]
                getAppDelegate().setCompassTimeout()
                cell.valueTextField.text = values[row].secondsRepresentable()
            default:
                break
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let indexPath = self.activeIndexPath, let values = self.activeValues else {
            fatalError("User Pressed but there is no indexPath/Values.")
        }
        if indexPath.row == 0 {
            return values[row].timeRepresentable()
        }
        return values[row].secondsRepresentable()
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let values = activeValues else {
            fatalError("Values are nil while fetching title.")
        }
        return values.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}
