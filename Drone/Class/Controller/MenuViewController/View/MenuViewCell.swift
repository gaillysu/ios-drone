//
//  MenuViewCell.swift
//  Drone
//
//  Created by Karl-John on 7/3/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import UIKit
import Font_Awesome_Swift

class MenuViewCell: UICollectionViewCell{
    
    @IBOutlet weak var menuItemLabel: UILabel!
    @IBOutlet var menuItemImage: UIImageView!
    
    var menuItem:MenuItem?{
        didSet{
            menuItemLabel.text = menuItem?.title()
            if let faIcon = menuItem?.icon() {
                menuItemImage.setFAIconWithName(icon: faIcon, textColor: UIColor.getDarkBaseColor())
            }else if let image = menuItem?.image(){
                menuItemImage.image = image
            }
        }
    }
}
