//
//  HotKeyTableViewCellButton.swift
//  Drone
//
//  Created by Karl-John Chow on 9/5/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import UIKit
import Font_Awesome_Swift


class HotKeyTableViewCellButton: UIButton {
    
    func selected(selected:Bool){
        if !selected{
            tintColor = UIColor.getBaseColor()
            self.setBackgroundColor(color: .white, forState: .normal)
            setTitleColor(.getBaseColor(), for: .normal)
            layer.borderColor = UIColor.getBaseColor().cgColor
            layer.borderWidth = 1.0
        }else{
            tintColor = UIColor.white
            self.setBackgroundColor(color: .getBaseColor(), forState: .normal)
            setTitleColor(.white, for: .normal)
            layer.borderColor = UIColor.white.cgColor
            layer.borderWidth = 0.0
        }
    }
}
