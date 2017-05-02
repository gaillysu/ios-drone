import Foundation

/*
Sets a goal to the given value
*/
class SetGoalRequest : DroneRequest {
    
    /*
    This header is the key by which this kind of packet is called.
    */
    class func HEADER() -> UInt8 {
        return 0x12
    }

    fileprivate var goal : Int
    
    init (goal : UserGoal) {
        self.goal = goal.goalSteps
    }
    
    init(steps:Int){
        self.goal = steps
    }
    
    override func getRawDataEx() -> [Data] {
        let goal_steps = goal
        let values1 :[UInt8] = [0x80,SetGoalRequest.HEADER(),
            UInt8(goal_steps&0xFF),
            UInt8((goal_steps>>8)&0xFF),
            UInt8((goal_steps>>16)&0xFF),
            UInt8((goal_steps>>24)&0xFF)
            ,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        return [Data(bytes: UnsafePointer<UInt8>(values1), count: values1.count)]
    }
    
}
