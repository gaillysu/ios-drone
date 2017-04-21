//
//  Float+Extension.swift
//  Nevo
//
//  Created by Cloud on 2016/12/27.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit

extension Float {
    func to2Float() -> Float {
        return NSString(format: "%.2f", self).floatValue
    }
    
    func toZeroFloat() -> Float {
        return NSString(format: "%.0f", self).floatValue
    }
}
