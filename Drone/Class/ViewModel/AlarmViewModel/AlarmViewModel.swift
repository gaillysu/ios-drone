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
        alarm.forEach { self.data.value[0].items.append(AlarmSectionViewModelItem(key: $0.key)) }
    }
    
    func getAlarmFor(index:Int) -> MEDAlarm?{
        return MEDAlarm.byFilter("key == '\(self.data.value[0].items[index].key)'").first ?? nil
    }
    
    func getAlarmFor(key:String) -> MEDAlarm?{
        return MEDAlarm.byFilter("key == '\(key)'").first ?? nil
    }
    
    // This function does not work properly.
    func delete(index:Int){
        let alarmKey = self.data.value[0].items[index].key
        if let alarm = getAlarmFor(key: alarmKey){
            if !alarm.isInvalidated{
                _ = alarm.remove()
            }
        }
        self.data.value[0].items.remove(at: index)
    }
}
