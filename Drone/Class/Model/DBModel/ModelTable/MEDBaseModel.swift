//
//  MEDBaseModel.swift
//  Nevo
//
//  Created by Cloud on 2016/11/10.
//  Copyright © 2016年 Nevo. All rights reserved.
//

import UIKit
import RealmSwift


class MEDBaseModel: Object,MEDDataBaseRequest {
    
    func add()->Bool {
        let realm = try! Realm()
        do {
            try realm.write {
                realm.add(self, update: true)
            }
        } catch let error {
            print("data base error:\(error)")
            return false
        }
        return true
    }
    
    func remove()->Bool{
        let realm = try! Realm()
        do {
            try realm.write {
                realm.delete(self)
            }
        } catch let error {
            debugPrint("write database error:\(error)")
            return false
        }
        return true
    }
    
    static func removeAll()->Bool{
        let realm = try! Realm()
        let selfObject = realm.objects(self)
        for object in selfObject {
            do {
                try realm.write {
                    realm.delete(object)
                }
            } catch let error {
                debugPrint("write database error:\(error)")
                return false
            }
        }
        return true
    }
    
    static func getFilter(_ criteria:String)->[Any]{
        let realm = try! Realm()
        let selfObject = realm.objects(self).filter(criteria)
        var value:[Any] = []
        for object in selfObject {
            value.append(object)
        }
        return value
    }
    
    static func getAll()->[Any]{
        let realm = try! Realm()
        let selfObject = realm.objects(self)
        var value:[Any] = []
        for object in selfObject {
            value.append(object)
        }
        return value
    }
}
