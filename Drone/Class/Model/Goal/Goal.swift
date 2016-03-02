//
//  Goal.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation
import CoreData

/*
This class represents all goals,
being steps count, calorie count etc...
*/

protocol Goal {

    func getType() ->String
    
    func getGoalIntensity() -> GoalIntensity
    
    func getValue() -> Int

}

enum GoalIntensity:UInt8 {
    case LOW, MEDIUM, HIGH
}