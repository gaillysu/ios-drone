//
//  YouDeviceViewController.swift
//  Drone
//
//  Created by leiyuncun on 16/4/20.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit

private let reuseIdentifier = "device_cell_identifier"

class WhichDeviceViewController: BaseViewController {

    @IBOutlet weak var backB: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    fileprivate var toMenu:Bool = true;
    init(toMenu:Bool) {
        self.toMenu = toMenu
        super.init(nibName: "WhichDeviceViewController", bundle: Bundle.main)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Device"
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        addCloseButton(#selector(backButton))
    }


    @IBAction func pairLaterAction(_ sender: AnyObject) {
        if(self.toMenu){
        self.present(self.makeStandardUINavigationController(MenuViewController()), animated: true, completion: nil);
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidLayoutSubviews() {
        let flowLayout:UICollectionViewFlowLayout = UICollectionViewFlowLayout();
        flowLayout.scrollDirection = UICollectionViewScrollDirection.vertical
        flowLayout.itemSize = CGSize(width: self.collectionView.frame.size.width/2.0-0.5, height: self.collectionView.frame.size.width/2.0)
        flowLayout.minimumLineSpacing = 1
        flowLayout.minimumInteritemSpacing = 1
        self.collectionView.collectionViewLayout = flowLayout
    }


    @IBAction func backButton() {
            if self.toMenu {
                _ = self.navigationController?.popViewController(animated: true)
            }else{
                self.dismiss(animated: true, completion: nil)
            }
    }

    // MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(_ collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        let view = cell.contentView.viewWithTag(1700)
        if view == nil {
            let watchView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.height))
            watchView.tag = 1700
            watchView.contentMode = .scaleAspectFit
            watchView.image = UIImage(named: String(format: "welcome_%d",(indexPath as NSIndexPath).row+1))
            cell.contentView.addSubview(watchView)
        }else{
            (view as! UIImageView).image = UIImage(named: String(format: "welcome_%d",(indexPath as NSIndexPath).row+1))
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: IndexPath) {
        let connection:ConnectionSetupViewController = ConnectionSetupViewController(toMenu: toMenu)
        connection.watchName = String(format: "welcome_%d",(indexPath as NSIndexPath).row+1)
        _ = UserDevice.removeAll()
        self.navigationController?.pushViewController(connection, animated: true)
    }
}
