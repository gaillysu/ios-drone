//
//  AnalysisFormatter.swift
//  Nevo
//
//  Created by Cloud on 2017/1/5.
//  Copyright © 2017年 Nevo. All rights reserved.
//

import UIKit
import Charts

class AnalysisFormatter: NSObject,IAxisValueFormatter,IValueFormatter {
    fileprivate var valueArray:[String] = []
    public init(xArray:[String]) {
        valueArray = xArray
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String{
        return "\(valueArray[Int(value)])"
    }
    
    public func stringForValue(_ value: Double,
                               entry: ChartDataEntry,
                               dataSetIndex: Int,
                               viewPortHandler: ViewPortHandler?) -> String{
        
        return ""
    }
}
