//
//  Color.swift
//  Drone
//
//  Created by Karl Chow on 4/27/16.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import UIColor_Hex_Swift

extension UIColor{
    
    public class func getBaseColor() -> UIColor {
        return UIColor(rgba: "#D19D42");
    }
    
    public class func getTintColor() -> UIColor {
        return UIColor(rgba: "#5D447A");
    }
    
    public class func getGreyColor() -> UIColor {
        return UIColor(rgba: "#666666");
    }
}