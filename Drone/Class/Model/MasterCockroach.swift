//
//  MasterCockroach.swift
//  Drone
//
//  Created by Karl-John on 22/9/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation

class MasterCockroach {
    
    let address:UUID
    var babyCockroaches:[BabyCockroach] = []
    
    init(address:UUID, babyCockroaches:[BabyCockroach]?) {
        self.address = address
        if let unpackedBabyCockroaches = babyCockroaches {
            self.babyCockroaches = unpackedBabyCockroaches
        }
    }
    
    init(WithMasterCockroachData data:CockroachMasterDataReceived){
        self.address = data.address
        self.babyCockroaches = [BabyCockroach(number: data.babyCockroachNumber, coordinateSet: data.coordinates)]
    }
    
    func addOrUpdateBabyCockroach(number:Int, coordinateSet: CoordinateSet){
        for baby in self.babyCockroaches{
            if baby.number == number {
                baby.coordinateSet = coordinateSet
                return
            }
        }
        self.babyCockroaches.append(BabyCockroach(number: number, coordinateSet: coordinateSet))
    }
    
    func addOrUpdateBabyCockroach(byCockroachMasterDataReceived data:CockroachMasterDataReceived){
        if data.address == address {
            for baby in  self.babyCockroaches{
                if baby.number == data.babyCockroachNumber {
                    baby.coordinateSet = data.coordinates
                    return
                }
            }
            self.babyCockroaches.append(BabyCockroach(number: data.babyCockroachNumber, coordinateSet: data.coordinates))
        }
    }
    
    
    
    func getBabyCockroach(at index:Int) -> BabyCockroach{
        return babyCockroaches[index]
    }
    
    func getAmountBabies() -> Int {
        return babyCockroaches.count
    }
}
