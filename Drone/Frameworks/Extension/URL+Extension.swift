//
//  URL+Extension.swift
//  Nevo
//
//  Created by Cloud on 2016/12/29.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import Foundation

extension URL {
    static func bundleURL(name: String) -> URL? {
        let url = Bundle.main.url(forResource: name, withExtension: "realm")
        return url
    }
}
