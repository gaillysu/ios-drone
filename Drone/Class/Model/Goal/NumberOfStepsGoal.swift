import Foundation

class NumberOfStepsGoal : Goal {
    
    let NUMBER_OF_STEPS = "NUMBER_OF_STEPS"
    
    let LOW_INTENSITY_STEPS = 7000
    
    let MEDIUM_INTENSITY_STEPS = 10000

    let HIGH_INTENSITY_STEPS = 20000
    
    fileprivate var mSteps:Int
    
    init(steps:Int=0) {

        mSteps = steps
        
    }
    
    init(intensity:GoalIntensity) {
        
        mSteps = 0
        
        if(intensity==GoalIntensity.low) {
            mSteps = LOW_INTENSITY_STEPS
        }
        
        if(intensity==GoalIntensity.medium) {
            mSteps = MEDIUM_INTENSITY_STEPS
        }
        
        if(intensity==GoalIntensity.high) {
            mSteps = HIGH_INTENSITY_STEPS
        }
    }
    
    func getType() -> String {
        return NUMBER_OF_STEPS
    }
    
    func getGoalIntensity() -> GoalIntensity {
        if(mSteps<=LOW_INTENSITY_STEPS) {
            return GoalIntensity.low
        }
        
        if(mSteps<=MEDIUM_INTENSITY_STEPS) {
            return GoalIntensity.medium
        }
        
        return GoalIntensity.high

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
