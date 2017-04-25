//
//  UICollectionViewCellExtension.swift
//  Drone
//
//  Created by Karl-John Chow on 24/4/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import UIKit

extension UICollectionViewCell {
    
    func enable(on: Bool) {
        isUserInteractionEnabled = on
        for view in contentView.subviews {
            view.isUserInteractionEnabled = on
            view.alpha = on ? 1 : 0.5
        }
    }
}
