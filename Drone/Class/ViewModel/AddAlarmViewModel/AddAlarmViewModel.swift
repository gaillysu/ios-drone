//
//  AddAlarmViewController.swift
//  Drone
//
//  Created by Karl-John Chow on 20/6/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import Foundation
import RxDataSources
import RxSwift
import RealmSwift

class AddAlarmViewModel{
    
    private let alarm:MEDAlarm
    
    let inEditMode:Bool
    var mustSync = false

    
    let data:Variable<[SectionModel<String, (title:String,detail:String)>]>
    var notificationToken:NotificationToken?
    
    var snoozable: Bool {
        set { self.alarm.update(operation: { $0.snoozable = newValue }) }
        get { return alarm.snoozable }
    }
    
    var alarmLabel:String {
        set{
            self.alarm.update(operation: { $0.label = newValue })
            data.value[0].items[1].detail = newValue
        }
        get{ return self.alarm.label }
    }
    
    var time:(hour:Int, minute:Int) {
        set {
            let hour  = newValue.hour
            let minute  = newValue.minute
            if hour < 24 && minute < 60  {
                alarm.update(operation: {
                    $0.hour = hour
                    $0.minute = minute
                })
                self.mustSync = true
            }
        }
        get {
            return (alarm.hour, alarm.minute)
        }
    }
    
    init(alarm:MEDAlarm = MEDAlarm(), inEditMode:Bool = false) {
        self.alarm = alarm
        self.inEditMode = inEditMode
        if !inEditMode{
            mustSync = true
        }
        
        
        data = Variable([SectionModel(model: "", items: [("Repeat",""),
                                                         ("Label",alarm.label),
                                                         ("Snooze","")])])
        self.alarm.update(operation: { _ in })
        notificationToken = self.alarm.addNotificationBlock { object in
            self.mustSync = true
            self.data.value[0].items[0].detail = alarm.repeatLabel()
        }
        if inEditMode{
            data.value.append(SectionModel(model: "", items: [("","")]))
            
        }
    }
    
    func deleteAlarm(){
        let realm = try! Realm()
        try! realm.write {
            realm.delete(alarm)
        }
    }
    
    func repeatViewModel() -> RepeatAlarmViewModel{
        return RepeatAlarmViewModel(alarm: alarm)
    }
    
    func syncAlarms(){
        if mustSync{
            AppDelegate.getAppDelegate().sendRequest(SetDailyAlarmRequest(alarmWeekDay: MEDAlarm.byFilter("enabled = \(true)")))
        }else{
            print("Not really needed to sync.")
        }
    }
    
}
