//
//  MenuItem.swift
//  Drone
//
//  Created by Karl Chow on 3/9/16.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation

class MenuItem {
    var menuViewControllerItem: UIViewController
    var menuTitle: String
    var image:UIImage
    var commingSoon:Bool
    
    init(controller: UIViewController, title: String, image: UIImage) {
        self.menuViewControllerItem = controller
        self.menuTitle = title
        self.commingSoon = false
        self.image = image
    }

}