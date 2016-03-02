//
//  NevoProtocol.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation
import CoreBluetooth

/*
A Profile is a set of GATT values that defines a device
🚧🚧🚧Backbone Class : Modify with care🚧🚧🚧
*/

protocol Profile {
    /**
    The control Service is a GATT service that contains several charactersitics
    */
    var CONTROL_SERVICE : CBUUID { get }
    
    /**
    The control characteristic receives requests as a write without response command
    */
    var CONTROL_CHARACTERISTIC : CBUUID { get }
    
    /**
    The callback characterisitc is notified of the device's response
    */
    var CALLBACK_CHARACTERISTIC : CBUUID { get }
}