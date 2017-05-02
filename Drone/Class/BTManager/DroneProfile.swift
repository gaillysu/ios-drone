import Foundation
import CoreBluetooth

/** 
*/
class DroneProfile : Profile {

    var CONTROL_SERVICE:CBUUID {
        return CBUUID(string: "F0BA3120-6CAC-4C99-9089-4B0A1DF45002");
    }

    var CONTROL_CHARACTERISTIC:CBUUID {
        return CBUUID(string: "F0BA3121-6CAC-4C99-9089-4B0A1DF45002");
    }

    var CALLBACK_CHARACTERISTIC:CBUUID {
        return CBUUID(string: "F0BA3121-6CAC-4C99-9089-4B0A1DF45002");
    }
}
