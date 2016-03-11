//
//  StepController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/2.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit
import CircleProgressView
import Charts

let NUMBER_OF_STEPS_GOAL_KEY = "NUMBER_OF_STEPS_GOAL_KEY"

class StepsViewController: BaseViewController,UIActionSheetDelegate {

    @IBOutlet weak var circleProgressView: CircleProgressView!
    // TODO eventbus: Steps, small & big sync
    @IBOutlet weak var stepsLabel: UILabel!
    
    @IBOutlet weak var barChart: BarChartView!
    @IBOutlet weak var percentageLabel: UILabel!

    init() {
        super.init(nibName: "StepsViewController", bundle: NSBundle.mainBundle())
        self.tabBarItem.title="Steps"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(animated: Bool) {
        barChart!.noDataText = "No History Available."
        barChart!.descriptionText = "";
        barChart!.pinchZoomEnabled = false
        barChart!.doubleTapToZoomEnabled = false;
        barChart!.legend.enabled = false;
        barChart!.dragEnabled = true
        let xAxis:ChartXAxis = barChart!.xAxis;
        xAxis.labelTextColor = UIColor.whiteColor();
        xAxis.axisLineColor = UIColor.whiteColor();
        let yXaxis:ChartYAxis = barChart!.leftAxis;
        yXaxis.labelTextColor = UIColor.whiteColor();
        yXaxis.axisLineColor = UIColor.whiteColor();
        barChart!.rightAxis.enabled = false;
        barChart!.zoom(14, scaleY: 1, xIndex: 0, yValue: 0, axis: .Left);
        // 14 is hard coded, should be 100 / 14 = 7, no mather what 100 is, 7 must come out.
        xAxis.labelPosition = ChartXAxis.XAxisLabelPosition.Bottom
        let stepsArray: NSMutableArray = NSMutableArray();
        let now = NSDate();
        
        for var j = 0; j < 100; j++ {
            let steps = Int(arc4random_uniform(6000) + 1000)
            let date:NSDate = now - j.day;
            stepsArray.addObject(UserSteps(keyDict:["id":j,"steps":steps,"hourlysteps":"","date":(date.timeIntervalSince1970)]));
        }
        // Need to get some Goal somewhere arround, for now Goal is 10000
        let goal = 10000;
        let today:UserSteps = stepsArray[0] as! UserSteps
        let percentage = (Double(today.steps)/Double(goal)) * 100
        circleProgressView.setProgress(Double(today.steps)/Double(goal), animated: true)
        stepsLabel.text = String(format:"%d steps",today.steps)
        percentageLabel.text = String(format:"Goal: %.1f%%",percentage)
        
        
        barChart.drawBarShadowEnabled = false
        var xVals = [String]();
        var yVals = [ChartDataEntry]();
        
        for var i = 0; i < stepsArray.count; i++ {
            let steps:UserSteps = stepsArray[i] as! UserSteps
            yVals.append(BarChartDataEntry(value: Double(steps.steps), xIndex:i));
            let dateOfSteps:NSDate = NSDate(timeIntervalSinceReferenceDate: steps.date)
            let calendar = NSCalendar.currentCalendar()
            let components = calendar.components([.Day, .Month], fromDate: dateOfSteps)
            let day =  components.day
            let month = components.month
            xVals.append(String(format: "%d/%d", arguments: [day,month]));
            let barChartSet:BarChartDataSet = BarChartDataSet(yVals: yVals, label: "Steps")
            let dataSet = NSMutableArray()
            dataSet.addObject(barChartSet);
            barChartSet.colors = [UIColor.whiteColor()]
            barChartSet.highlightColor = AppTheme.BASE_COLOR_TINT()
            barChartSet.valueColors = [UIColor.whiteColor()]
            let barChartData = BarChartData(xVals: xVals, dataSet: barChartSet)
            self.barChart.data = barChartData;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
