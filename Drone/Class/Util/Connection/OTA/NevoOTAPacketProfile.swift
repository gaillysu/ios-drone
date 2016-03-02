//
//  NevoProfile.swift
//  Nevo
//
//  Created by Hugo Garcia-Cotte on 20/1/15.
//  Copyright (c) 2015 Nevo. All rights reserved.
//

import Foundation
import CoreBluetooth

/**
This is the OTA Packet Profile
It is used to send OTA Packets while doing OTA
This Profile doesn't expect responses
🚧🚧🚧Backbone Class : Modify with care🚧🚧🚧
*/
class NevoOTAPacketProfile : Profile {
    
    var CONTROL_SERVICE:CBUUID {
        return CBUUID(string: "00001530-1212-EFDE-1523-785FEABCD123");
    }
    
    var CONTROL_CHARACTERISTIC:CBUUID {
        return CBUUID(string: "00001532-1212-EFDE-1523-785FEABCD123");
    }
    
    var CALLBACK_CHARACTERISTIC:CBUUID {
        
        return CBUUID(string: "00001531-1212-EFDE-1523-785FEABCD123");
    }
}