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
        return UIColor(red: 209/255.0 , green: 157/255.0, blue: 66/255.0, alpha: 1)
        
    }

    public class func getDarkBaseColor() -> UIColor {
        return UIColor("#987332");
    }
 
    public class func getTintColor() -> UIColor {
        return UIColor("#5D447A");
    }
    
    public class func getGreyColor() -> UIColor {
        return UIColor("#666666");
    }
    
    public class func getColor(hex:String) -> UIColor {
        return UIColor(hex);
    }
    
    public class func getLightBaseColor() -> UIColor {
        return UIColor(red: 209/255.0 , green: 157/255.0, blue: 66/255.0, alpha: 0.6)
    }

    public class func transparent() -> UIColor {
        return UIColor(red: 0/255.0 , green: 0/255.0, blue: 0/255.0, alpha: 0.0)
    }

}
