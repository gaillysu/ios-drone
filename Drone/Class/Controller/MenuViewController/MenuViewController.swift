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
        StepsManager.sharedInstance.syncLastSevenDaysData()
        setupRx()
    }
    
    func reloadMenuItems() {
        var item:MenuItem = LoginMenuItem()
        if UserProfile.getAll().count>0 {
            item = ProfileMenuItem()
        }
        if self.menuItems.value.count>7 {
            self.menuItems.value.replaceSubrange(6..<7, with: [item])
        }else{
            self.menuItems.value.insert(item, at: 6)
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
        collectionView.cellForItem(at: indexPath)?.backgroundColor = .white
    }
}

