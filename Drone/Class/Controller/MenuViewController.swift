//
//  MenuViewController.swift
//  Drone
//
//  Created by Karl-John on 7/3/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation

class MenuViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate  {
    
    let identifier = "menu_cell_identifier"
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.registerClass(MenuViewCell.self, forCellWithReuseIdentifier: identifier)
        collectionView.registerNib(UINib(nibName: "MenuViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: identifier)
        print(self.navigationController?.navigationBar.frame.size.height)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:MenuViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! MenuViewCell
//        cell.menuItemLabel.text = "my title"
        return cell
    }
}