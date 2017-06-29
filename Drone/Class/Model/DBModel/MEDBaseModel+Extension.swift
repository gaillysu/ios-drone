//
//  MEDBaseModel+Extension.swift
//  Drone
//
//  Created by Karl-John Chow on 19/6/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import Foundation

//
//  MEDBaseModel+Ex.swift
//  LunaR
//
//  Created by Quentin on 26/5/17.
//  Copyright © 2017年 MED Enterprises Limited. All rights reserved.
//

import Foundation
import RealmSwift

protocol RealmOperable {
    
    associatedtype T
    
    func update(add: Bool, operation: @escaping (T) -> Void)
    
    var isManaged: Bool { get }
    
    func findAll() -> [T]
    
    static func findAll() -> [T]
    
    static func byFilter(_ predicate:String) -> [T]
    
}


// MARK: - Implemention
extension RealmOperable where Self: Object {
    
    func update(add: Bool = true, operation: @escaping (Self) -> Void) {
        let realm = try! Realm()
        try! realm.write {
            operation(self)
            
            if add {
                realm.add(self, update: true)
            }
        }
    }
    
    var isManaged: Bool {
        let realm = try! Realm()
        return realm.objects(Self.self).filter("key == %@", self.value(forKeyPath: "key") ?? "").count > 0
    }
    
    func findAll() -> [Self] {
        let realm = try! Realm()
        return realm.objects(Self.self).map{ $0 }
    }
    
    static func findAll() -> [Self] {
        let realm = try! Realm()
        return realm.objects(self).map{ $0 }
    }
    
    static func byFilter(_ predicate:String) -> [Self] {
        let realm = try! Realm()
        return realm.objects(self).filter(predicate)
            .map{ $0 }
    }
}


extension MEDBaseModel: RealmOperable {}
