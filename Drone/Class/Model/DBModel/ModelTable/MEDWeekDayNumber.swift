//
//  MEDWeekDayNumber.swift
//  Drone
//
//  Created by Karl-John Chow on 19/6/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import Foundation
import RealmSwift

class MEDWeekDayNumber:MEDBaseModel {
    // Starts with Sunday. 
    dynamic var weekDay = 0
}

extension MEDWeekDayNumber:Comparable{
    /// Returns a Boolean value indicating whether the value of the first
    /// argument is less than that of the second argument.
    ///
    /// This function is the only requirement of the `Comparable` protocol. The
    /// remainder of the relational operator functions are implemented by the
    /// standard library for any type that conforms to `Comparable`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    static func <(lhs: MEDWeekDayNumber, rhs: MEDWeekDayNumber) -> Bool {
        return lhs.weekDay == rhs.weekDay
    }

    static func == (lhs: MEDWeekDayNumber, rhs: MEDWeekDayNumber) -> Bool {
        return lhs.weekDay == rhs.weekDay
    }
}
