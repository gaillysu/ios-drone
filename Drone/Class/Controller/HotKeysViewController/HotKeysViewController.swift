//
//  HotKeysViewController.swift
//  Drone
//
//  Created by Karl-John Chow on 5/5/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

class HotKeysViewController: UIViewController {
    
    let identifier = "UITableViewCell"
    let hotKeyIdentifier = "HotKeyTableViewCell"
    
    @IBOutlet weak var tableview: UITableView!
    
    var enableSwitch:UISwitch = UISwitch()
    var selectedFeature = Variable(HotKey.Feature.disabled)
    
    var disposeBag = DisposeBag()
    let section = Variable([HotKeySectionModel(header: "", footer: "Hot Keys makes your watch even more useful! Enable the Hot Keys and select your favorite function below.", items: [HotKeySectionModelItem(label: "Enable", imageName: "icon_star")])])
    let functionSectionModel = HotKeySectionModel(header: "Select Function", footer: "If your Dayton watch is not connected, it will sync as soon as it gets connected.", items: [HotKeySectionModelItem(label: "", imageName: nil)])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Hot Keys"
        selectedFeature.value = HotKey.Feature(fromRawValue: DTUserDefaults.topKeySelection)
        enableSwitch.tintColor = UIColor.getBaseColor()
        enableSwitch.onTintColor = UIColor.getBaseColor()
        if selectedFeature.value.rawValue > 0{
            enableSwitch.setOn(true, animated: true)
            section.value.append(functionSectionModel)
        }
        self.addCloseButton(#selector(closeAction))
        tableview.register(UINib(nibName: hotKeyIdentifier, bundle: Bundle.main), forCellReuseIdentifier: hotKeyIdentifier)
        
        let dataSource = RxTableViewSectionedAnimatedDataSource<HotKeySectionModel>()
        dataSource.animationConfiguration = AnimationConfiguration(insertAnimation: .fade,
                                                                   reloadAnimation: .automatic,
                                                                   deleteAnimation: .fade)
        
        dataSource.configureCell = { (dataSource, tableView, indexPath, item ) in
            if indexPath.section == 0 {
                var cell = tableView.dequeueReusableCell(withIdentifier: self.identifier)
                if cell == nil {
                    cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: self.identifier)
                }
                cell?.textLabel?.text = item.label
                if let name = item.imageName{
                    cell?.imageView?.image = UIImage(named: name)
                }
                cell?.accessoryView = self.enableSwitch
                return cell!
            }
            
            let cell: HotKeyTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.selectedFeature.value = self.selectedFeature.value
            cell.selectedFeature.asObservable().bind(to: self.selectedFeature).addDisposableTo(self.disposeBag)
            return cell
        }
        
        dataSource.titleForHeaderInSection = { dataSource, index in
            let section = dataSource[index]
            return section.header
        }
        
        dataSource.titleForFooterInSection = { dataSource, index in
            let section = dataSource[index]
            return section.footer
        }
        
        section.asObservable()
            .bind(to: tableview.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)
        
        tableview.rx
            .itemSelected
            .subscribe({ event in
                if let indexPath = event.element{
                    self.tableview.deselectRow(at: indexPath, animated: true)
                }
            }).addDisposableTo(self.disposeBag)
        
        selectedFeature.asObservable()
            .debounce(0.3, scheduler: MainScheduler.instance)
            .subscribe { event in
                print(self.selectedFeature.value.rawValue)
                DTUserDefaults.topKeySelection = self.selectedFeature.value.rawValue
                self.getAppDelegate().setTopKeyCustomization()
        }.addDisposableTo(self.disposeBag)
        
        self.tableview.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        self.enableSwitch.rx
            .controlEvent(UIControlEvents.valueChanged)
            .delay(0.15, scheduler: MainScheduler.instance)
            .subscribe { (_) in
                if !self.enableSwitch.isOn && self.section.value.count == 2{
                    self.selectedFeature.value = HotKey.Feature(fromRawValue: (self.selectedFeature.value.rawValue * -1))
                    self.section.value.remove(at: 1)
                }else if self.section.value.count == 1{
                    self.selectedFeature.value = HotKey.Feature(fromRawValue: abs(self.selectedFeature.value.rawValue))
                    self.section.value.insert(self.functionSectionModel, at: 1)
                }
            }.addDisposableTo(disposeBag)
    }
    
    func closeAction(){
        self.dismiss(animated: true, completion: nil)
    }
}

extension HotKeysViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 134.0
        }
        return 44.0
    }
}
