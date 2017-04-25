//
//  EveryHourWeatherModel.swift
//  Drone
//
//  Created by Cloud on 2017/4/21.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit

class EveryHourWeatherModel: NSObject,NSCoding {
    var dt:String =  ""
    var temp:String = ""
    var code:String = ""
    var stateText:String = ""
    var dt_txt:String = ""
    
    override init() {
        super.init()
    }
    
    func encode(with aCoder:NSCoder) {
        aCoder.encode(dt, forKey:"dt")
        aCoder.encode(temp, forKey:"temp")
        aCoder.encode(code, forKey:"code")
        aCoder.encode(stateText, forKey:"stateText")
        aCoder.encode(dt_txt, forKey:"dt_txt")
    }
    
    required init(coder aDecoder:NSCoder) {
        super.init()
        if let cDt = aDecoder.decodeObject(forKey:"dt") {
            dt = cDt as! String
        }
        
        if let ctemp = aDecoder.decodeObject(forKey:"temp") {
            temp = ctemp as! String
        }
        
        if let ccode = aDecoder.decodeObject(forKey:"code") {
            code = ccode as! String
        }
        
        if let cText = aDecoder.decodeObject(forKey:"stateText") {
            stateText = cText as! String
        }
        
        if let cDt_txt = aDecoder.decodeObject(forKey:"dt_txt") {
            dt_txt = cDt_txt as! String
        }
    }
}
