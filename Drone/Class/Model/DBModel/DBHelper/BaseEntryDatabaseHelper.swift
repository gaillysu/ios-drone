//
//  BaseEntryDatabaseHelper.swift
//  Nevo
//
//  Created by leiyuncun on 15/11/18.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import Foundation

protocol BaseEntryDatabaseHelper {
    func add(_ result:((_ id:Int?,_ completion:Bool?) -> Void))
    func update()->Bool
    func remove()->Bool
    static func removeAll()->Bool
    static func getCriteria(_ criteria:String)->NSArray
    static func getAll()->NSArray
}
