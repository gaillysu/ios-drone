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
    
    func drawSettings(_ xAxis:ChartXAxis, yAxis:ChartYAxis, rightAxis:ChartYAxis){
        noDataText = "No History Available."
        descriptionText = ""
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
        xAxis.labelPosition = ChartXAxis.LabelPosition.bottom
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
        let lineChartDataSet = LineChartDataSet(yVals: yVals, label: "");
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
        lineChartDataSet.fill = ChartFill.fillWithLinearGradient(gradient!, angle: CGFloat(90.0))
        lineChartDataSet.drawFilledEnabled = true
        let lineChartData = LineChartData(xVals: xVals, dataSet: lineChartDataSet)
        lineChartData.setDrawValues(false)
        data = lineChartData
        animate(yAxisDuration: 2.0, easingOption: ChartEasingOption.easeInOutCirc)
    }
    
    func reset(){
        xVals.removeAll();
        yVals.removeAll();
    }
}
