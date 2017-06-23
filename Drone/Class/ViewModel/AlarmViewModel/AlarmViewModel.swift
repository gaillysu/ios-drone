//
//  AlarmViewModel.swift
//  Drone
//
//  Created by Karl-John Chow on 19/6/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift

class AlarmViewModel{
    
    var disposeBag = DisposeBag()
    
    let data:Variable<[AlarmSectionViewModel]>
    var bedtimeNotificationToken:NotificationToken?
    init() {
        let realm = try! Realm()
        let alarm = realm.objects(MEDAlarm.self)
        data = Variable([AlarmSectionViewModel(header: "My Alarms", items: [])])
        alarm.forEach { self.data.value[0].items.append(AlarmSectionViewModelItem(alarm: $0)) }
    }
    
    func getAlarmFor(index:Int) -> MEDAlarm?{
        if (self.data.value[0].items.count - 1) >= index{
            return self.data.value[0].items[index].alarm
        }
        return nil
    }
    
    // This function does not work properly.
    func delete(index:Int){
        let realm = try! Realm()
        let alarms = realm.objects(MEDAlarm.self)
        if alarms.count > index {
            do {
                try realm.write {
                    realm.delete(alarms[index])
                }
            }catch let error{
                debugPrint("write database error:\(error)")
            }
        }
        self.data.value[0].items.remove(at: index)
    }
}
