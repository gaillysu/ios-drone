//
//  StepHistoricalViewController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/31.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit
import Charts

class StepHistoricalViewController: UIViewController,ChartViewDelegate {

    @IBOutlet weak var lineChart: LineChartView?
    var options:[[String:String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "History"

        self.options = [["key": "toggleValues", "label": "Toggle Values"],["key": "toggleFilled", "label": "Toggle Filled"],["key": "toggleCircles", "label": "Toggle Circles"],["key": "toggleCubic", "label": "Toggle Cubic"],["key": "toggleHighlight", "label": "Toggle Highlight"],["key": "toggleStartZero", "label": "Toggle StartZero"],["key": "animateX", "label": "Animate X"],["key": "animateY", "label": "Animate Y"],["key": "animateXY", "label": "Animate XY"],["key": "saveToGallery", "label": "Save to Camera Roll"],["key": "togglePinchZoom", "label": "Toggle PinchZoom"],["key": "toggleAutoScaleMinMax", "label": "Toggle auto scale min/max"]];

        lineChart!.descriptionText = " ";
        lineChart?.noDataText = NSLocalizedString("no_sleep_data", comment: "")
        lineChart!.noDataTextDescription = "";
        lineChart!.pinchZoomEnabled = true
        lineChart!.drawGridBackgroundEnabled = false;
        let xScale:CGFloat = CGFloat(63)/35.0;//integer/integer = integer,float/float = float
        lineChart!.setScaleMinima(xScale, scaleY: 1)
        lineChart!.setScaleEnabled(false);
        lineChart!.doubleTapToZoomEnabled = false;
        lineChart!.setViewPortOffsets(left: 0.0, top: 0.0, right: 0.0, bottom: 0.0)
        lineChart!.delegate = self

        let leftAxis:ChartYAxis = lineChart!.leftAxis;
        leftAxis.valueFormatter = NSNumberFormatter();
        leftAxis.drawAxisLineEnabled = false;
        leftAxis.drawGridLinesEnabled = true;
        leftAxis.enabled = false;
        leftAxis.spaceTop = 0.6;

        let marker:BalloonMarker = BalloonMarker(color: UIColor(white: 180/255.0, alpha: 1.0), font: UIFont.systemFontOfSize(12.0), insets: UIEdgeInsetsMake(8.0, 8.0, 20.0, 8.0))
        marker.minimumSize = CGSizeMake(80.0, 40.0);
        lineChart!.marker = marker;
        lineChart!.legend.form = ChartLegend.ChartLegendForm.Line


        lineChart!.rightAxis.enabled = false;

        let xAxis:ChartXAxis = lineChart!.xAxis;
        xAxis.labelFont = UIFont.systemFontOfSize(8)
        xAxis.drawAxisLineEnabled = false;
        xAxis.drawGridLinesEnabled = false;
        xAxis.labelPosition = ChartXAxis.XAxisLabelPosition.BottomInside

        lineChart!.legend.enabled = false;
        setDataCount(19+1, range: 30)
        lineChart!.animate(xAxisDuration: 2.5)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setDataCount(count:Int,range:Double) {
        var xVals:[String] = []
        for (var i:Int = 0; i < count; i++) {
            xVals.append("1/\(i)")
        }
        var yVals:[ChartDataEntry] = []
        for (var i:Int = 0; i < count; i++) {
            let mult:Double = Double(range) / Double(2.0)
            let val:Double = Double(arc4random_uniform(UInt32(mult))+50)
            yVals.append(ChartDataEntry(value: val, xIndex: i))
        }

        let set1:LineChartDataSet = LineChartDataSet(yVals: yVals, label: "DataSet 1")
        set1.axisDependency = ChartYAxis.AxisDependency.Left;

        set1.setColor(AppTheme.NEVO_SOLAR_YELLOW())
        set1 .setCircleColor(UIColor.whiteColor())
        set1.lineWidth = 2.0;
        set1.circleRadius = 3.0;
        set1.fillAlpha = 65/255.0;
        set1.fillColor = AppTheme.NEVO_SOLAR_YELLOW()
        set1.highlightColor = AppTheme.NEVO_SOLAR_YELLOW()
        set1.drawCircleHoleEnabled = false
        set1.drawCirclesEnabled = !set1.isDrawCirclesEnabled;
        set1.drawCubicEnabled = !set1.isDrawCubicEnabled;
        set1.drawValuesEnabled = !set1.isDrawValuesEnabled;

        var yVals2:[ChartDataEntry] = []

        for (var i:Int = 0; i < count; i++) {
            let mult:Double = range;
            let val:Double = Double(arc4random_uniform(UInt32(mult)) + 450)
            yVals2.append(ChartDataEntry(value: val, xIndex: i))
        }
        var dataSets:[LineChartDataSet] = []
        dataSets.append(set1)

        let data:LineChartData = LineChartData(xVals: xVals, dataSets: dataSets)
        data.setValueTextColor(UIColor.whiteColor())
        data.setValueFont(UIFont.systemFontOfSize(9.0))
        lineChart!.data = data;
    }

    // MARK: - ChartViewDelegate
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {

        NSLog("chartValueSelected")
    }

    func chartValueNothingSelected(chartView: ChartViewBase) {
        NSLog("chartValueNothingSelected")
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
