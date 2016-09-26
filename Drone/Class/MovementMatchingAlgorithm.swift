//
//  MovementMatchingAlgorithm.swift
//  Drone
//
//  Created by Karl-John on 23/9/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation

class MovementMatchingAlgorithm {
    
    /* Currently optimized only for 1 master cockroach.
     instruction should be instruction:Instruction instead of CoordinateSerie
     correctInput should be CoordinateSerie
     
     */
    let amountFailedMovements:Int
    var finishedRepetitions:Int = 0
    let instruction:CoordinateSerie
    let threshold:Int
    var hardMode:Bool = false

    var correctInput:[Vector] = []
    var skippedIndexForSensor:[Int : Int] = [:]
    
    let repetitionFinishedCallback: ((Void) -> Void)
    var equalCallback: ((Void) -> Void)?
    var resetCallback: ((Void) -> Void)?
    var previousInputCoordinate:CoordinateSet?
    
    init(withInstruction instruction:Instruction, repCompleteCallback callback: @escaping ((Void) -> Void), threshold:Int, amountFailedMovements:Int){
        self.threshold = threshold
        self.instruction = instruction.coordinateSeries[0]
        self.repetitionFinishedCallback = callback
        self.amountFailedMovements = amountFailedMovements
    }
    
    
    func addMovement(byMasterCockroachData masterCockroachData:CockroachMasterDataReceived){
        addMovement(babyCockroachNumber: masterCockroachData.babyCockroachNumber, coordinateSet: masterCockroachData.coordinates)
    }
    
    func addMovement(byBabyCockroach babyCockroach: BabyCockroach){
        if let coordinateSet = babyCockroach.coordinateSet{
            addMovement(babyCockroachNumber: babyCockroach.number, coordinateSet: coordinateSet)
        }else{
            print("There is something wrong.")
        }
    }
 
    func setEqualCallback(_ callback:@escaping ((Void) -> Void)) {
        self.equalCallback = callback
    }
    
    func setResetCallback(_ callback:@escaping ((Void) -> Void)) {
        self.resetCallback = callback
    }
    
    private func addMovement(babyCockroachNumber:Int, coordinateSet:CoordinateSet){
        if let previousInput = previousInputCoordinate {
            let inputVector = Vector(withCoordinates: coordinateSet, right: previousInput)
            let mustMatch = instruction.coordinateSets[((correctInput.count - 1) < 0 ?  0 : (correctInput.count - 1))]
            let mustMatchNext = instruction.coordinateSets[(correctInput.count + 1 < instruction.coordinateSets.count ? (correctInput.count + 1) : instruction.coordinateSets.count - 1)]
            let comparedVector = Vector(withCoordinates: mustMatch, right: mustMatchNext)
            print("Vector Input = \(inputVector.getString())")
            print("Vector Match = \(comparedVector.getString())")
            if mustMatch.sensorNumber == babyCockroachNumber {
                if inputVector.equal(self.threshold, otherVector: comparedVector) {
                    if let unpackedEqualCallback = self.equalCallback{
                        unpackedEqualCallback()
                    }
                    print("Equal!")
                    correctInput.append(inputVector)
                    if let _ = self.skippedIndexForSensor[coordinateSet.sensorNumber]{
                        self.skippedIndexForSensor[coordinateSet.sensorNumber] = 0
                    }
                    if correctInput.count == instruction.coordinateSets.count {
                        print("One repetition Finished!")
                        self.finishedRepetitions += 1
                        self.repetitionFinishedCallback()
                        self.reset()
                        return
                    }
                }else if hardMode {
                    if let skipped = self.skippedIndexForSensor[coordinateSet.sensorNumber]{
                        if skipped >= self.amountFailedMovements {
                            self.reset()
                            if let unpackedResetCallback = self.resetCallback{
                                unpackedResetCallback()
                            }
                            return
                        }
                        self.skippedIndexForSensor[coordinateSet.sensorNumber] = self.skippedIndexForSensor[coordinateSet.sensorNumber]! + 1
                    }else{
                        self.skippedIndexForSensor[coordinateSet.sensorNumber] = 1
                    }
                }
            }
        }else{
            print(coordinateSet.getString())
            print(instruction.coordinateSets[0].getString())
            if coordinateSet.equal(self.threshold, otherCoordinateSet: instruction.coordinateSets[0]) {
                self.previousInputCoordinate = coordinateSet
            }
            return
        }
    }
    
        
    
    private func reset(){
        self.previousInputCoordinate = nil
        self.skippedIndexForSensor.removeAll()
        self.correctInput.removeAll()
    }
}
