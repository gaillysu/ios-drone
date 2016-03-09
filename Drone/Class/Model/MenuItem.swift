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
    
    init(controller: UIViewController, title: String) {
        self.menuViewControllerItem = controller;
        self.menuTitle = title;
    }
}