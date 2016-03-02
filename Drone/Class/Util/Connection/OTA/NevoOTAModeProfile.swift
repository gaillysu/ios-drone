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
This profile have only one use :
It sends a request to the Nevo watch and force it to change to OTA mode
This profile doesn't expect a callback
🚧🚧🚧Backbone Class : Modify with care🚧🚧🚧
*/
class NevoOTAModeProfile : Profile {
    
    var CONTROL_SERVICE:CBUUID {
        return CBUUID(string: "F0BA3020-6CAC-4C99-9089-4B0A1DF45002");
    }
    
    var CONTROL_CHARACTERISTIC:CBUUID {
        return CBUUID(string: "F0BA3023-6CAC-4C99-9089-4B0A1DF45002");
    }
    
    var CALLBACK_CHARACTERISTIC:CBUUID {
   
        return CBUUID(string: "F0BA3023-6CAC-4C99-9089-4B0A1DF45002");
    }
}