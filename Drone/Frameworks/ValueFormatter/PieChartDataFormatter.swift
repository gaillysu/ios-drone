//
//  PieChartDataFormatter.swift
//  Nevo
//
//  Created by Cloud on 2017/1/9.
//  Copyright © 2017年 Nevo. All rights reserved.
//

import UIKit
import Charts

class PieChartDataFormatter: NSObject,IValueFormatter, IAxisValueFormatter {
    fileprivate var valueArray:[String] = [NSLocalizedString("Solar", comment: ""),NSLocalizedString("Battery", comment: "")]
    public override init() {
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String{
        return valueArray[Int(value)]
    }
    
    public func stringForValue(_ value: Double,
                               entry: ChartDataEntry,
                               dataSetIndex: Int,
                               viewPortHandler: ViewPortHandler?) -> String{
        
        return ""
    }
}
