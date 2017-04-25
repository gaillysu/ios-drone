//
//  MEDBanner.swift
//  Nevo
//
//  Created by Quentin on 12/10/16.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import Foundation
import BRYXBanner

class MEDBanner:Banner {
    public required init(title: String? = nil, subtitle: String? = nil, image: UIImage? = nil, backgroundColor: UIColor = UIColor.black, didTapBlock: (() -> ())? = nil) {
        super.init(title: title, subtitle: subtitle, image: image, backgroundColor: UIColor.getBaseColor(), didTapBlock: didTapBlock)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
