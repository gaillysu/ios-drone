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
            bedtimeNotificationToken = alarm.addNotificationBlock { notification in
            switch notification {
            case .initial:
                break
            case .update(_, let _, let _, let _):
                break
            case .error(_):
                break
            }
        }
        data = Variable([AlarmSectionViewModel(header: "My Alarms", items: [])])
        alarm.forEach { self.data.value[0].items.append(AlarmSectionViewModelItem(alarm: $0)) }
    }
    
    func getAlarmFor(index:Int) -> MEDAlarm?{
        if (self.data.value[0].items.count - 1) >= index{
            return self.data.value[0].items[index].alarm
        }
        return nil
    }
    
    func delete(index:Int){
        if (self.data.value[0].items.count - 1) >= index{
            self.data.value[0].items.remove(at: index)
        }
    }
}
