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
This is the regular Nevo Profile
It is used to send most common commands to Nevo
🚧🚧🚧Backbone Class : Modify with care🚧🚧🚧
*/
class DroneProfile : Profile {

    var CONTROL_SERVICE:CBUUID {
        return CBUUID(string: "F0BA3020-6CAC-4C99-9089-4B0A1DF45002");
    }

    var CONTROL_CHARACTERISTIC:CBUUID {
        return CBUUID(string: "F0BA3021-6CAC-4C99-9089-4B0A1DF45002");
    }

    var CALLBACK_CHARACTERISTIC:CBUUID {
        return CBUUID(string: "F0BA3021-6CAC-4C99-9089-4B0A1DF45002");
    }
}

//This is a tiger -----> 🐯