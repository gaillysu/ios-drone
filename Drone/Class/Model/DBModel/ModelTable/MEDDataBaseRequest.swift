//
//  MEDDataBaseRequest.swift
//  Nevo
//
//  Created by Cloud on 2016/11/8.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import RealmSwift

protocol MEDDataBaseRequest {
    func add()->Bool
    func remove()->Bool
    static func removeAll()->Bool
    static func getFilter(_ criteria:String)->[Any]
    static func getAll()->[Any]
}
