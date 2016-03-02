//
//  NumberOfStepsGoal.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation

class NumberOfStepsGoal : Goal {
    
    let NUMBER_OF_STEPS = "NUMBER_OF_STEPS"
    
    let LOW_INTENSITY_STEPS = 7000
    
    let MEDIUM_INTENSITY_STEPS = 10000

    let HIGH_INTENSITY_STEPS = 20000
    
    private var mSteps:Int
    
    init(steps:Int=0) {

        mSteps = steps
        
    }
    
    init(intensity:GoalIntensity) {
        
        mSteps = 0
        
        if(intensity==GoalIntensity.LOW) {
            mSteps = LOW_INTENSITY_STEPS
        }
        
        if(intensity==GoalIntensity.MEDIUM) {
            mSteps = MEDIUM_INTENSITY_STEPS
        }
        
        if(intensity==GoalIntensity.HIGH) {
            mSteps = HIGH_INTENSITY_STEPS
        }
    }
    
    func getType() -> String {
        return NUMBER_OF_STEPS
    }
    
    func getGoalIntensity() -> GoalIntensity {
        if(mSteps<=LOW_INTENSITY_STEPS) {
            return GoalIntensity.LOW
        }
        
        if(mSteps<=MEDIUM_INTENSITY_STEPS) {
            return GoalIntensity.MEDIUM
        }
        
        return GoalIntensity.HIGH

    }
    
    func getValue() -> Int {
        return mSteps
    }
    
}

/*
🐾
 🐾
🐾
  🐾
 🐾
*/