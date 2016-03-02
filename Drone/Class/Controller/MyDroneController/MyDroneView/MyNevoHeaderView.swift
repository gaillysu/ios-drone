//
//  MyNevoHeaderView.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/3.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class MyNevoHeaderView: UIImageView {

    class func getMyNevoHeaderView()->UIImageView {
        let nibView:NSArray = NSBundle.mainBundle().loadNibNamed("MyNevoHeaderView", owner: nil, options: nil)
        return nibView.objectAtIndex(0) as! UIImageView
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
