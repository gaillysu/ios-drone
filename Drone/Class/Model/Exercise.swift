//
//  ExerciseSet.swift
//  Drone
//
//  Created by Karl-John on 26/8/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import RealmSwift

class Exercise: Object {
    dynamic var instruction: Instruction? = nil
    dynamic var finishedRepetitions = 0
    
}