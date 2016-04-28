//
//  YouDeviceViewController.swift
//  Drone
//
//  Created by leiyuncun on 16/4/20.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit

private let reuseIdentifier = "device_cell_identifier"

class WhichDeviceViewController: UIViewController {

    @IBOutlet weak var backB: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    init() {
        super.init(nibName: "WhichDeviceViewController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.backgroundColor = UIColor.whiteColor()
        self.collectionView!.registerNib(UINib(nibName: "MenuViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }


    override func viewDidLayoutSubviews() {
        let flowLayout:UICollectionViewFlowLayout = UICollectionViewFlowLayout();
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
        flowLayout.itemSize = CGSizeMake(self.collectionView.frame.size.width/2.0-0.5, self.collectionView.frame.size.width/2.0+20)
        flowLayout.minimumLineSpacing = 1
        flowLayout.minimumInteritemSpacing = 1
        self.collectionView.collectionViewLayout = flowLayout

    }


    @IBAction func buttonActionManager(sender: AnyObject) {
        if (sender.isEqual(backB)) {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
        cell.backgroundColor = UIColor.grayColor()
        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let connection:ConnectionSetupViewController = ConnectionSetupViewController()
        self.navigationController?.pushViewController(connection, animated: true)
    }
}
