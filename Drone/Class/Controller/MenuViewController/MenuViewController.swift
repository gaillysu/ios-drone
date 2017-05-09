//
//  MenuViewController.swift
//  Drone
//
//  Created by Karl-John on 7/3/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import SwiftEventBus

import MRProgress
import SwiftyJSON
import SwiftyTimer
import UIKit
import RealmSwift
import RxSwift
import RxCocoa
import Font_Awesome_Swift

class MenuViewController: BaseViewController  {
    
    @IBOutlet weak var menuCollectionView: UICollectionView!
    
    let identifier = "menu_cell_identifier"
    var disposeBag = DisposeBag()
    var menuItems: Variable<[MenuItem]> = Variable([StepsMenuItem(), TimeMenuItem(),CityNavigationMenuItem(), CompassMenuItem(), HotKeyMenuItem(), NotificationsMenuItem(),DeviceMenuItem()])
    
    init() {
        super.init(nibName: "MenuViewController", bundle: Bundle.main)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        reloadMenuItems()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        menuCollectionView.register(UINib(nibName: "MenuViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: identifier)
        menuCollectionView.clipsToBounds = true
        AppDelegate.getAppDelegate().startConnect()
        if NetworkManager.manager.getNetworkState() {
            StepsManager.sharedInstance.syncLastSevenDaysData()
        }
        
        _ = SwiftEventBus.onMainThread(self, name: SWIFTEVENT_BUS_GET_SYSTEM_STATUS_KEY) { (notification) -> Void in
            let data:[UInt8] = Constants.NSData2Bytes((notification.object as! RawPacketImpl).getRawData())
            NSLog("SWIFTEVENT_BUS_GET_SYSTEM_STATUS_KEY  :\(data)")
        }
        
        _ = SwiftEventBus.onMainThread(self, name: SWIFTEVENT_BUS_CONNECTION_STATE_CHANGED_KEY) { (notification) -> Void in
            let connectionState:Bool = notification.object as! Bool
            if(connectionState){
                let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(1.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                    AppDelegate.getAppDelegate().readsystemStatus()
                })
            }
        }
        
        _ = SwiftEventBus.onMainThread(self, name: SWIFTEVENT_BUS_END_BIG_SYNCACTIVITY) { (notification) in
            MRProgressOverlayView.dismissAllOverlays(for: self.navigationController!.view, animated: true)
            
            let stepsArray = UserSteps.getFilter("syncnext == \(false)")
            var dayDateArray:[Date] = []
            for steps in stepsArray{
                let userSteps:UserSteps = steps as! UserSteps
                let date:Date = Date(timeIntervalSince1970: userSteps.date).beginningOfDay
                dayDateArray.append(date)
            }
            
            if NetworkManager.manager.getNetworkState() {
                StepsManager.sharedInstance.syncServiceDayData(dayDateArray)
            }
        }
        
        _ = SwiftEventBus.onMainThread(self, name: SWIFTEVENT_BUS_BIG_SYNCACTIVITY_DATA) { (notification) in
            let data:PostActivityData = notification.object as! PostActivityData
            let steps:Int = data.step
            let timerInterval:Int = data.stepsDate
            if (steps != 0) {
                let stepsArray = UserSteps.getFilter("date == \(timerInterval)")
                if(stepsArray.count>0) {
                    let step:UserSteps = stepsArray[0] as! UserSteps
                    NSLog("Data that has been saved····")
                    let realm = try! Realm()
                    try! realm.write({
                        step.steps = steps
                        step.date = TimeInterval(timerInterval)
                        step.syncnext = true
                    })
                }else {
                    let stepsModel:UserSteps = UserSteps()
                    stepsModel.id = Int(Date().timeIntervalSince1970)
                    stepsModel.distance = 0
                    stepsModel.steps = steps
                    stepsModel.date = TimeInterval(timerInterval)
                    stepsModel.syncnext = false
                    _ = stepsModel.add()
                }
            }
        }
        setupRx()
    }
    
    func reloadMenuItems() {
        if UserProfile.getAll().count>0 {
            if self.menuItems.value.count>7 {
                self.menuItems.value.replaceSubrange(6..<7, with: [ProfileMenuItem()])
            }else{
                self.menuItems.value.insert(ProfileMenuItem(), at: 6)
            }
        }else{
            if self.menuItems.value.count>7 {
                self.menuItems.value.replaceSubrange(6..<7, with: [LoginMenuItem()])
            }else{
                self.menuItems.value.insert(LoginMenuItem(), at: 6)
            }
        }
    }
    
    func setupRx(){
        menuItems.asObservable().bind(to: menuCollectionView
            .rx
            .items(cellIdentifier: identifier, cellType: MenuViewCell.self)){
                row, menuItem, cell in
                cell.menuItem = menuItem
                cell.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 0)
                if row == 0 {
                    cell.roundCorners(corners: .topLeft, radius: 10)
                } else if row == 1 {
                    cell.roundCorners(corners: .topRight, radius: 10)
                } else if row == 6 {
                    cell.roundCorners(corners: .bottomLeft, radius: 10)
                } else if row == 7 {
                    cell.roundCorners(corners: .bottomRight, radius: 10)
                }
            }.addDisposableTo(disposeBag)
        menuCollectionView.delegate = self
    }
}

extension MenuViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let widthAndHeight = (collectionView.layer.bounds.width - 12) / 2
        return CGSize(width: widthAndHeight, height: widthAndHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let item:MenuItem = self.menuItems.value[indexPath.row]
        let controller = item.viewController()
        controller.navigationItem.title = item.title()
        let navigationViewController = makeStandardUINavigationController(controller)
        if indexPath.row == 6 && UserProfile.getAll().first == nil {
            navigationViewController.navigationBar.isHidden = true
        } else if indexPath.row == 7 {
            DTUserDefaults.presentMenu = false
        }
        self.present(navigationViewController, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.backgroundColor = UIColor("#EBEBEB")
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.backgroundColor = UIColor.white
    }
}

