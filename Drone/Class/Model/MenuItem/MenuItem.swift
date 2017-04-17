//
//  MenuItem.swift
//  Drone
//
//  Created by Karl Chow on 3/9/16.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import UIKit
import Font_Awesome_Swift

protocol MenuItem {
    
    func viewController() -> UIViewController
    
    func icon() -> FAType?
    
    func image() -> UIImage?
    
    func title() -> String

    func comingSoon() -> Bool
}
