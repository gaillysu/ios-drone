//
//  AnalysisStepsChartView.swift
//  Drone
//
//  Created by Karl-John on 29/4/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import Charts

class AnalysisStepsChartView: LineChartView {

    fileprivate var xVals:[String] = [];
    fileprivate var yVals:[ChartDataEntry] = [];
    
    func drawSettings(_ xAxis:XAxis, yAxis:YAxis, rightAxis:YAxis){
        noDataText = "No History Available."
        chartDescription?.text = ""
        dragEnabled = false
        setScaleEnabled(false)
        pinchZoomEnabled = false
        legend.enabled = false
        rightAxis.enabled = true

        let goal:UserGoal = UserGoal.getAll()[0] as! UserGoal
        let limitLine = ChartLimitLine(limit: Double(goal.goalSteps),label: "Goal");
        limitLine.lineWidth = 1.5
        limitLine.labelPosition = ChartLimitLine.LabelPosition.leftTop
        limitLine.valueFont = UIFont(name: "Helvetica-Light", size: 7)!
        limitLine.lineColor = UIColor.getGreyColor()
        
        rightAxis.axisLineColor = UIColor.getGreyColor()
        rightAxis.drawGridLinesEnabled = false;
        rightAxis.drawLimitLinesBehindDataEnabled = false
        rightAxis.drawLabelsEnabled = false;
        rightAxis.drawZeroLineEnabled = false
        
        yAxis.axisMaxValue = Double(goal.goalSteps)+700
        yAxis.axisMinValue = 0
        yAxis.axisLineColor = UIColor.getGreyColor()
        yAxis.drawGridLinesEnabled = false
        
        yAxis.drawLabelsEnabled = false
        yAxis.drawZeroLineEnabled = true
        yAxis.addLimitLine(limitLine)
        xAxis.labelTextColor = UIColor.getGreyColor();
        xAxis.axisLineColor = UIColor.getGreyColor()
        xAxis.drawLimitLinesBehindDataEnabled = false;
        xAxis.labelPosition = XAxis.LabelPosition.bottom
        xAxis.labelFont = UIFont(name: "Helvetica-Light", size: 7)!
        
        let marker:BalloonMarker = BalloonMarker(color: UIColor.getBaseColor(), font: UIFont(name: "Helvetica-Light", size: 11)!, insets: UIEdgeInsetsMake(8.0, 8.0, 15.0, 8.0))
        marker.minimumSize = CGSize(width: 60, height: 25);
        self.marker = marker;
    }
    
    func addDataPoint(_ name:String, entry:ChartDataEntry){
        xVals.append(name);
        yVals.append(entry)
    }
    
    func invalidateChart() {
        let formatter:ChartFormatter = ChartFormatter(xVals)
        let xaxis:XAxis = XAxis()
        for (index,_) in xVals.enumerated() {
            _ = formatter.stringForValue(Double(index), axis: nil)
        }
        xaxis.valueFormatter = formatter
        self.xAxis.valueFormatter = xaxis.valueFormatter
        
        let lineChartDataSet = LineChartDataSet(values: yVals, label: "");
        lineChartDataSet.setColor(UIColor.getGreyColor())
        lineChartDataSet.setCircleColor(UIColor.getGreyColor())
        lineChartDataSet.lineWidth = 1.5
        lineChartDataSet.setColor(UIColor.getGreyColor())
        lineChartDataSet.circleRadius = 5.0
        lineChartDataSet.drawCircleHoleEnabled = false
        lineChartDataSet.valueFont = UIFont.systemFont(ofSize: 9.0)
        
        let colorLocations:[CGFloat] = [0.0, 1.0]
        let gradientColors = NSArray(array: [ChartColorTemplates .colorFromString("#D19D42").cgColor,ChartColorTemplates .colorFromString("#552582").cgColor]);
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations);
        lineChartDataSet.fillAlpha = 0.5;
        lineChartDataSet.fill = Fill.fillWithLinearGradient(gradient!, angle: CGFloat(90.0))
        lineChartDataSet.drawFilledEnabled = true
        let lineChartData = LineChartData(dataSet: lineChartDataSet)
        lineChartData.setDrawValues(false)
        data = lineChartData
        animate(yAxisDuration: 2.0, easingOption: ChartEasingOption.easeInOutCirc)
    }
    
    func reset(){
        xVals.removeAll();
        yVals.removeAll();
    }
}

class StepsBarChartView: BarChartView {
    
    func drawSettings(_ xAxis:XAxis, yAxis:YAxis, rightAxis:YAxis){
        
        noDataText = NSLocalizedString("no_data_selected_date", comment: "")
        chartDescription?.text = ""
        doubleTapToZoomEnabled = false
        legend.enabled = false
        dragEnabled = true
        rightAxis.enabled = true
        setScaleEnabled(false)
        
        let xAxis:XAxis = xAxis
        xAxis.labelTextColor = UIColor.gray
        xAxis.axisLineColor = UIColor.gray
        xAxis.drawAxisLineEnabled = true
        xAxis.drawGridLinesEnabled = true
        xAxis.labelPosition = XAxis.LabelPosition.bottom
        xAxis.labelFont = UIFont(name: "Helvetica-Light", size: 7)!
        
        let yAxis:YAxis = leftAxis
        yAxis.labelTextColor = UIColor.gray
        yAxis.axisLineColor = UIColor.gray
        yAxis.drawAxisLineEnabled  = true
        yAxis.drawGridLinesEnabled  = true
        yAxis.drawLimitLinesBehindDataEnabled = true
        yAxis.axisMinimum = 0
        yAxis.setLabelCount(5, force: true)
        
        let rightAxis:YAxis = rightAxis
        rightAxis.labelTextColor = UIColor.clear
        rightAxis.axisLineColor = UIColor.gray
        rightAxis.drawAxisLineEnabled  = true
        rightAxis.drawGridLinesEnabled  = true
        rightAxis.drawLimitLinesBehindDataEnabled = true
        rightAxis.drawZeroLineEnabled = true
        
        rightAxis.enabled = false
        drawBarShadowEnabled = false
    }
    
    func invalidateChart(date:Date) ->(lastSteps:Int,lastTimeframe:Int) {
        let value =  self.calculateTodayData(date: date)
        
        leftAxis.axisMaximum = value.axisMaxValue
        xAxis.valueFormatter = value.xAxisformatter
        
        let barChartSet:BarChartDataSet = BarChartDataSet(values: value.yVals, label: "")
        let dataSet = NSMutableArray()
        dataSet.add(barChartSet);
        barChartSet.colors = [UIColor.getBaseColor()]
        barChartSet.highlightColor = UIColor.getBaseColor()
        barChartSet.valueColors = [UIColor.getGreyColor()]
        let barChartData = BarChartData(dataSet: barChartSet)
        barChartData.setDrawValues(false)
        
        if value.lastSteps>0 {
            data = barChartData
        }else{
            data = nil
        }
        
        animate(yAxisDuration: 2.0, easingOption: ChartEasingOption.easeInOutCirc)
        return (value.lastSteps,value.lastTimeframe)
    }
    
    fileprivate func calculateTodayData(date:Date) ->(axisMaxValue:Double,xAxisformatter:ChartFormatter,yVals:[ChartDataEntry],lastSteps:Int,lastTimeframe:Int) {
        var Xvals = [String]();
        var Yvals = [ChartDataEntry]();
        var maxValue:Double = 0
        
        var lastSteps:Int = 0
        var lastTimeframe:Int = 0
        var max:Double = 0
        
        for i in 0 ..< 24 {
            let dayDate:Date = date
            let dayTime:TimeInterval = Date(year: dayDate.year, month: dayDate.month, day: dayDate.day, hour: i, minute: 0, second: 0).timeIntervalSince1970
            let hours = UserSteps.getFilter("date >= \(dayTime) AND date <= \(dayTime+3600-1)")
            
            var hourData:Double = 0
            for (index,userSteps) in hours.enumerated() {
                let hSteps:UserSteps = userSteps as! UserSteps
                hourData += Double(hSteps.steps)
                if hSteps.steps>0 {
                    debugPrint("Hour Steps:\(hSteps.steps)")
                    lastTimeframe += 5
                }
                if index == hours.count-1 {
                    if hourData > max {
                        max = hourData
                    }
                }
            }
            
            if(max > 500){
                while max.truncatingRemainder(dividingBy: 100) != 0 {
                    max += 1
                }
                maxValue = max
            }else{
                maxValue = 500
            }
            
            lastSteps += Int(hourData)
    
            if(i%6 == 0){
                Xvals.append("\(i):00")
            }else if(i == 23) {
                Xvals.append("\(i+1):00")
            }else{
                Xvals.append("")
            }
            
            Yvals.append(BarChartDataEntry(x: Double(i) ,y: hourData));
        }
        
        let formatter:ChartFormatter = ChartFormatter(Xvals)
        
        for (index,_) in Xvals.enumerated() {
            _ = formatter.stringForValue(Double(index), axis: nil)
        }
        let xaxis:XAxis = XAxis()
        xaxis.valueFormatter = formatter
        
        return (maxValue,formatter,Yvals,lastSteps,lastTimeframe)
    }
}
