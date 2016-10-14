//
//  MenuItem.swift
//  Drone
//
//  Created by Karl Chow on 3/9/16.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import UIKit

class MenuItem {
    var menuViewControllerItem: String
    var menuTitle: String
    var image:UIImage
    var commingSoon:Bool
    
    init(controllerName: String, title: String, image: UIImage) {
        self.menuViewControllerItem = controllerName
        self.menuTitle = title
        self.commingSoon = false
        self.image = image
    }

}
