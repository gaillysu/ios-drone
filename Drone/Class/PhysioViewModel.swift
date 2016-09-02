//
//  PhysioViewModel.swift
//  Drone
//
//  Created by Karl-John on 26/8/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation

class PhysioViewModel: NSObject {
    
    let name:String
    let createdDate:NSDate
    
    init(withExercise exercise:Exercise) {
        self.name = exercise.instruction!.name
        self.createdDate = exercise.instruction!.createdDate
    }
    
    init(withInstruction instruction:Instruction) {
        self.name = instruction.name
        self.createdDate = instruction.createdDate
    }
}