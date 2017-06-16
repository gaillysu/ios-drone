//
//  DRHUD.swift
//  Drone
//
//  Created by Cloud on 2017/6/15.
//  Copyright © 2017 Cloud. All rights reserved.
//

import Foundation
import PKHUD

class DRHUD: NSObject {
    
    class func showHudAndDissmiss(title:String?, subtitle:String?, duration:TimeInterval?, type:DRHudType, completion: ((Bool) -> Void)?){
        
        switch type {
        case .error:
            PKHUD.sharedHUD.contentView = PKHUDErrorView(title: title, subtitle: subtitle)
            break
        case.success:
            PKHUD.sharedHUD.contentView = PKHUDSuccessView(title: title, subtitle: subtitle)
            break
        }
        PKHUD.sharedHUD.show()
        if let unpackedDuration = duration {
            PKHUD.sharedHUD.hide(afterDelay: unpackedDuration, completion: completion)
        } else {
            PKHUD.sharedHUD.hide(afterDelay: 0.0, completion: completion)
        }
    }
    
    class func startLoading(title:String?, subtitle:String?, hide:TimeInterval?){
        PKHUD.sharedHUD.contentView = PKHUDProgressView(title: title, subtitle: subtitle)
        PKHUD.sharedHUD.show()
        if let unpackedHide = hide {
            PKHUD.sharedHUD.hide(afterDelay: unpackedHide)
        }
    }
    
    class func hide(hideAfter:TimeInterval?, completion: ((Bool) -> Void)?){
        var hideTime:TimeInterval = 0.0
        if let unpackedHideAfter = hideAfter {
            hideTime = unpackedHideAfter
        }
        PKHUD.sharedHUD.hide(afterDelay: hideTime, completion: completion)
    }
    
    public enum DRHudType{
        case error
        case success
    }
}
