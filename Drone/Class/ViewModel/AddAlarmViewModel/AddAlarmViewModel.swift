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

class AddAlarmViewModel{
    
    private let alarm:MEDAlarm
    
    let data:Variable<[SectionModel<String, (title:String,detail:String)>]>
    
    var snoozable: Bool {
        set { self.alarm.snoozable = newValue }
        get { return alarm.snoozable }
    }
    
    var alarmLabel:String {
        set{ self.alarm.label = newValue}
        get{ return self.alarm.label }
    }
    
    var time:(hour:Int, minute:Int){
        set {
            let hour  = newValue.hour
            let minute  = newValue.minute
            if hour < 24 { alarm.update(operation: { $0.hour = hour }) }
            if minute < 60 { alarm.update(operation: { $0.minute = minute }) }
        }
        get {
            return (alarm.hour, alarm.minute)
        }
    }
    
    init(alarm:MEDAlarm = MEDAlarm()) {
        self.alarm = alarm
        data = Variable([SectionModel(model: "", items: [("Repeat",""),
                                                         ("Label",alarm.label),
                                                         ("Snooze","")]),
                SectionModel(model: "", items: [("","")])])
        data.value[0].items[0].detail = alarm.repeatLabel()
    }
    
}
