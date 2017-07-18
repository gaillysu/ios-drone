//
//  NordicDFUDelegate.swift
//  Drone
//
//  Created by Karl-John Chow on 17/7/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol NordicDFUDelegate {
    
    func deviceFound(peripherals:[CBPeripheral])
    
}
