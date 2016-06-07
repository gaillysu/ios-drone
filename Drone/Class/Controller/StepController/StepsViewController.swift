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
import Timepiece
import UIColor_Hex_Swift
import CVCalendar
import Timepiece
import SwiftEventBus
import XCGLogger


let NUMBER_OF_STEPS_GOAL_KEY = "NUMBER_OF_STEPS_GOAL_KEY"

private let CALENDAR_VIEW_TAG = 1800
class StepsViewController: BaseViewController,UIActionSheetDelegate {

    @IBOutlet var mainview: UIView!
    @IBOutlet weak var circleProgressView: CircleProgressView!
    // TODO eventbus: Steps, small & big sync
    @IBOutlet weak var lastMiles: UILabel!
    @IBOutlet weak var lastCalories: UILabel!
    @IBOutlet weak var lastActiveTime: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    
    @IBOutlet weak var barChart: BarChartView!
    @IBOutlet weak var percentageLabel: UILabel!

    @IBOutlet weak var thisWeekMiles: UILabel!
    @IBOutlet weak var thisWeekCalories: UILabel!
    @IBOutlet weak var thisWeekActiveTime: UILabel!
    @IBOutlet weak var thisWeekChart: AnalysisStepsChartView!
    
    
    @IBOutlet weak var lastWeekCalories: UILabel!
    @IBOutlet weak var lastWeekMiles: UILabel!
    @IBOutlet weak var lastWeekActiveTime: UILabel!
    @IBOutlet weak var lastWeekChart: AnalysisStepsChartView!
    
    @IBOutlet weak var lastMonthChart: AnalysisStepsChartView!
    @IBOutlet weak var lastMonthActiveTime: UILabel!
    @IBOutlet weak var lastMonthMiles: UILabel!
    @IBOutlet weak var lastMonthCalories: UILabel!
    
    var calendarView:CVCalendarView?
    var menuView:CVCalendarMenuView?
    var titleView:StepsTitleView?
    private var queryTimer:NSTimer?

    init() {
        super.init(nibName: "StepsViewController", bundle: NSBundle.mainBundle())
        self.tabBarItem.title="Steps"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initTitleView()
        let goal:UserGoal = UserGoal.getAll()[0] as! UserGoal
        percentageLabel.text = String(format:"Goal: %d",goal.goalSteps)
        self.navigationController?.navigationBar.backItem?.backBarButtonItem?.image = nil;
        stepsLabel.text = "0"
        
        SwiftEventBus.onMainThread(self, name: SWIFTEVENT_BUS_SMALL_SYNCACTIVITY_DATA) { (notification) in
            let stepsDict:[String:Int] = notification.object as! [String:Int]
            self.setCircleProgress(stepsDict["dailySteps"]! , goalValue: stepsDict["goal"]!)
        }
        
        queryTimer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(StepsViewController.queryStepsGoalAction(_:)), userInfo: nil, repeats: true)
    }

    override func viewWillAppear(animated: Bool) {
        self.bulidChart(NSDate())
    }

    override func viewDidDisappear(animated: Bool) {

        if queryTimer!.valid {
            queryTimer?.invalidate()
            queryTimer = nil
        }
    }

    func queryStepsGoalAction(timer:NSTimer) {
        AppDelegate.getAppDelegate().getGoal()
    }
}

extension StepsViewController {

    func setCircleProgress(stepsValue:Int,goalValue:Int) {
        circleProgressView.setProgress(Double(stepsValue)/Double(goalValue), animated: true)
        stepsLabel.text = String(format:"%d",stepsValue)
        
    }

    func bulidChart(todayDate:NSDate) {
        lastWeekChart.reset()
        lastMonthChart.reset()
        thisWeekChart.reset()
        
        barChart!.noDataText = "No History Available."
        barChart!.descriptionText = ""
        barChart!.pinchZoomEnabled = false
        barChart!.doubleTapToZoomEnabled = false
        barChart!.legend.enabled = false
        barChart!.dragEnabled = true
        barChart!.rightAxis.enabled = true
        
        let xAxis:ChartXAxis = barChart!.xAxis
        xAxis.labelTextColor = UIColor.grayColor()
        xAxis.axisLineColor = UIColor.grayColor()
        xAxis.drawAxisLineEnabled = true
        xAxis.drawGridLinesEnabled = true
        xAxis.labelPosition = ChartXAxis.XAxisLabelPosition.Bottom
        xAxis.labelFont = UIFont(name: "Helvetica-Light", size: 7)!

        let yAxis:ChartYAxis = barChart!.leftAxis
        yAxis.labelTextColor = UIColor.grayColor()
        yAxis.axisLineColor = UIColor.grayColor()
        yAxis.drawAxisLineEnabled  = true
        yAxis.drawGridLinesEnabled  = true
        yAxis.drawLimitLinesBehindDataEnabled = true
        
        let rightAxis:ChartYAxis = barChart!.rightAxis
        rightAxis.labelTextColor = UIColor.clearColor()
        rightAxis.axisLineColor = UIColor.grayColor()
        rightAxis.drawAxisLineEnabled  = true
        rightAxis.drawGridLinesEnabled  = true
        rightAxis.drawLimitLinesBehindDataEnabled = true
        rightAxis.drawZeroLineEnabled = true

        barChart!.rightAxis.enabled = false
        barChart.drawBarShadowEnabled = false
        var xVals = [String]();
        var yVals = [ChartDataEntry]();
        
        var lastSteps:Int = 0
        var lastTimeframe:Int = 0
        var max:Int = 0
        for i in 0 ..< 24 {
            let dayDate:NSDate = todayDate
            
            let dayTime:NSTimeInterval = NSDate.date(year: dayDate.year, month: dayDate.month, day: dayDate.day, hour: i, minute: 0, second: 0).timeIntervalSince1970
            let hours:NSArray = UserSteps.getCriteria("WHERE date BETWEEN \(dayTime) AND \(dayTime+3600)") //one hour = 3600s
            
            var hourData:Double = 0
            for userSteps in hours {
                let hSteps:UserSteps = userSteps as! UserSteps
                hourData += Double(hSteps.steps)
                if hSteps.steps>0 {
                    lastTimeframe += 5
                    if hSteps.steps>max {
                        max = hSteps.steps
                    }
                }
            }
            
            lastSteps += Int(hourData)
            yVals.append(BarChartDataEntry(value: hourData, xIndex:i));
            if(i%6 == 0){
                xVals.append("\(i):00")
            }else if(i == 23) {
                xVals.append("\(i+1):00")
            }else{
                xVals.append("")
            }

            let barChartSet:BarChartDataSet = BarChartDataSet(yVals: yVals, label: "Steps")
            let dataSet = NSMutableArray()
            dataSet.addObject(barChartSet);
            barChartSet.colors = [UIColor.getBaseColor()]
            barChartSet.highlightColor = UIColor.getBaseColor()
            barChartSet.valueColors = [UIColor.getGreyColor()]
            let barChartData = BarChartData(xVals: xVals, dataSet: barChartSet)
            barChartData.setDrawValues(false)
            self.barChart.data = barChartData
        }
        
        yAxis.axisMinValue = 0
        yAxis.setLabelCount(5, force: true);
        if(max % 500 == 0){
            yAxis.axisMaxValue = Double((Int(max)/500)*500)
        }else{
            if Double(max)/500.0<0 {
                yAxis.axisMaxValue = 500
            }else{
                yAxis.axisMaxValue = Double(Int(String(format: "%.0f", Double(max)/500.0))!*500)
            }
        }
        
        //display selected today steps data
        let goal:GoalModel = GoalModel.getAll()[0] as! GoalModel
        self.setCircleProgress(Int(lastSteps) , goalValue: goal.goalSteps)
        
        if lastSteps>0 {
            calculationData(lastTimeframe,steps: lastSteps, completionData: { (miles, calories) in
                self.lastMiles.text = miles
                self.lastCalories.text = calories
                let timer:String = String(format: "%.2f",Double(lastTimeframe)/60)
                let timerArray = timer.componentsSeparatedByString(".")
                if Int(timerArray[0])>0 {
                    self.lastActiveTime.text = "\(timerArray[0])h \(String(format: "%.0f",Double("0."+timerArray[1])!*60))m"
                }else{
                    self.lastActiveTime.text = "\(timerArray[1])m"
                }
            })
        }
        
        
        barChart?.animate(yAxisDuration: 2.0, easingOption: ChartEasingOption.EaseInOutCirc)
        lastWeekChart.drawSettings(lastWeekChart.xAxis, yAxis: lastWeekChart.leftAxis, rightAxis: lastWeekChart.rightAxis)
        thisWeekChart.drawSettings(thisWeekChart.xAxis, yAxis: thisWeekChart.leftAxis, rightAxis: thisWeekChart.rightAxis)
        lastMonthChart.drawSettings(lastMonthChart.xAxis, yAxis: lastMonthChart.leftAxis, rightAxis: lastMonthChart.rightAxis)

        let oneWeekSeconds:Double = 604800
        let oneDaySeconds:Double = 86400
        
        var thisWeekSteps:Int = 0
        var thisWeekTime:Int = 0
        for i in 0 ..< 7 {
            let dayTimeInterval:NSTimeInterval = todayDate.beginningOfWeek.timeIntervalSince1970+(oneDaySeconds*Double(i))
            let dayDate:NSDate = NSDate(timeIntervalSince1970: dayTimeInterval)
            let dayTime:NSTimeInterval = NSDate.date(year: dayDate.year, month: dayDate.month, day: dayDate.day, hour: 0, minute: 0, second: 0).timeIntervalSince1970
            let hours:NSArray = UserSteps.getCriteria("WHERE date BETWEEN \(dayTime) AND \(dayTime+oneDaySeconds-1)")
            var hourData:Double = 0
            for userSteps in hours {
                let hSteps:UserSteps = userSteps as! UserSteps
                hourData += Double(hSteps.steps)
                if hSteps.steps>0 {
                    thisWeekTime+=5
                }
            }
            thisWeekSteps+=Int(hourData)
            let formatter = NSDateFormatter()
            formatter.dateFormat = "M/dd"
            let dateString = "\(formatter.stringFromDate(dayDate))"
            thisWeekChart.addDataPoint("\(dateString)", entry: BarChartDataEntry(value: hourData, xIndex:i))
        }
        
        if thisWeekSteps>0 {
            calculationData(thisWeekTime,steps: thisWeekSteps, completionData: { (miles, calories) in
                self.thisWeekMiles.text = miles
                self.thisWeekCalories.text = calories
                let timer:String = String(format: "%.2f",Double(thisWeekTime)/60)
                let timerArray = timer.componentsSeparatedByString(".")
                if Int(timerArray[0])>0 {
                    self.thisWeekActiveTime.text = "\(timerArray[0])h \(String(format: "%.0f",Double("0."+timerArray[1])!*60))m"
                }else{
                    self.thisWeekActiveTime.text = "\(timerArray[1])m"
                }
            })
        }

        var lastWeekSteps:Int = 0
        var lastWeekTime:Int = 0
        for i in 0 ..< 7 {
            let dayTimeInterval:NSTimeInterval = todayDate.beginningOfWeek.timeIntervalSince1970+(oneDaySeconds*Double(i))-oneWeekSeconds
            let dayDate:NSDate = NSDate(timeIntervalSince1970: dayTimeInterval)
            let dayTime:NSTimeInterval = NSDate.date(year: dayDate.year, month: dayDate.month, day: dayDate.day, hour: 0, minute: 0, second: 0).timeIntervalSince1970
            let hours:NSArray = UserSteps.getCriteria("WHERE date BETWEEN \(dayTime) AND \(dayTime+oneDaySeconds-1)")
            var hourData:Double = 0
            for userSteps in hours {
                let hSteps:UserSteps = userSteps as! UserSteps
                hourData += Double(hSteps.steps)
                if hSteps.steps>0 {
                    lastWeekTime+=5
                }
            }
            lastWeekSteps+=Int(hourData)
            
            let formatter = NSDateFormatter()
            formatter.dateFormat = "M/dd"
            let dateString = "\(formatter.stringFromDate(dayDate))"
            
            lastWeekChart.addDataPoint("\(dateString)", entry: BarChartDataEntry(value: hourData, xIndex:i))
        }
        
        if lastWeekSteps>0 {
            calculationData(lastWeekTime,steps: lastWeekSteps, completionData: { (miles, calories) in
                self.lastWeekMiles.text = miles
                self.lastWeekCalories.text = calories
                let timer:String = String(format: "%.2f",Double(lastWeekTime)/60)
                let timerArray = timer.componentsSeparatedByString(".")
                if Int(timerArray[0])>0 {
                    self.lastWeekActiveTime.text = "\(timerArray[0])h \(String(format: "%.0f",Double("0."+timerArray[1])!*60))m"
                }else{
                    self.lastWeekActiveTime.text = "\(timerArray[1])m"
                }
            })
        }

        let lastBeginningOfMonth:NSTimeInterval = todayDate.beginningOfDay.timeIntervalSince1970
        
        var lastMonthSteps:Int = 0
        var lastMonthTime:Int = 0
        for i in 0 ..< 30 {
            let monthTimeInterval:NSTimeInterval = lastBeginningOfMonth-oneDaySeconds*Double(i)
            let hours:NSArray = UserSteps.getCriteria("WHERE date BETWEEN \(monthTimeInterval) AND \(monthTimeInterval+oneDaySeconds-1)")
            var hourData:Double = 0
            for userSteps in hours {
                let hSteps:UserSteps = userSteps as! UserSteps
                hourData += Double(hSteps.steps)
                if hSteps.steps>0 {
                    lastMonthTime+=5
                }
            }
            lastMonthSteps+=Int(hourData)
            let formatter = NSDateFormatter()
            formatter.dateFormat = "M/dd"
            let dateString = "\(formatter.stringFromDate(NSDate(timeIntervalSince1970: monthTimeInterval)))"
            
            lastMonthChart.addDataPoint("\(dateString)", entry: BarChartDataEntry(value: hourData, xIndex:i))
        }
        
        if lastMonthSteps>0 {
            calculationData(lastMonthTime,steps: lastMonthSteps, completionData: { (miles, calories) in
                self.lastMonthMiles.text = miles
                self.lastMonthCalories.text = calories
                let timer:String = String(format: "%.2f",Double(lastMonthTime)/60)
                let timerArray = timer.componentsSeparatedByString(".")
                if Int(timerArray[0])>0 {
                    self.lastMonthActiveTime.text = "\(timerArray[0])h \(String(format: "%.0f",Double("0."+timerArray[1])!*60))m"
                }else{
                    self.lastMonthActiveTime.text = "\(timerArray[1])m"
                }
            })
            
        }
        
        lastWeekChart.invalidateChart()
        thisWeekChart.invalidateChart()
        lastMonthChart.invalidateChart()
    }
}

// MARK: - Data calculation
extension StepsViewController {

    func calculationData(activeTimer:Int,steps:Int,completionData:((miles:String,calories:String) -> Void)) {
        let profile:NSArray = UserProfile.getAll()
        let userProfile:UserProfile = profile.objectAtIndex(0) as! UserProfile
        let strideLength:Double = Double(userProfile.length)*0.415/100
        let miles:Double = strideLength*Double(steps)/1000
        //Formula's = (2.0 X persons KG X 3.5)/200 = calories per minute
        let calories:Double = (2.0*Double(userProfile.weight)*3.5)/200*Double(activeTimer)
        completionData(miles: String(format: "%.2f",miles), calories: String(format: "%.2f",calories))
    }
}

// MARK: - Title View
extension StepsViewController {

    func initTitleView() {
        titleView = StepsTitleView.getStepsTitleView(CGRectMake(0,0,190,50))
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMM"
        let dateString = "\(formatter.stringFromDate(NSDate())), \(NSDate().day)"
        titleView?.setCalendarButtonTitle(dateString)
        self.navigationItem.titleView = titleView
        titleView!.buttonResultHandler = { result -> Void in
            let clickButton:UIButton = result as! UIButton
            if (result!.isEqual(self.titleView!.calendarButton) && clickButton.selected) {
                self.showCalendar()
            }else if (result!.isEqual(self.titleView!.calendarButton) && !clickButton.selected) {
                self.dismissCalendar()
            }else if (result!.isEqual(self.titleView!.nextButton)) {
                self.calendarView!.loadNextView()
            }else if (result!.isEqual(self.titleView!.backButton)) {
                self.calendarView!.loadPreviousView()
            }
        }
    }

    func showCalendar() {
        let view = self.view.viewWithTag(CALENDAR_VIEW_TAG)
        if(view == nil) {
            let calendarBackGroundView:UIView = UIView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,self.view.frame.size.height))
            calendarBackGroundView.alpha = 0
            calendarBackGroundView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
            calendarBackGroundView.tag = CALENDAR_VIEW_TAG
            let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(StepsViewController.tapAction(_:)))
            calendarBackGroundView.addGestureRecognizer(tap)
            self.view.addSubview(calendarBackGroundView)

            let fillView:UIView = UIView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,280))
            fillView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(1)
            calendarBackGroundView.addSubview(fillView)

            self.menuView = CVCalendarMenuView(frame: CGRectMake(10, 40, UIScreen.mainScreen().bounds.size.width - 20, 20))
            self.menuView?.dayOfWeekTextColor = UIColor.whiteColor()
            self.menuView?.dayOfWeekTextColor = UIColor.grayColor()
            self.menuView?.dayOfWeekFont = UIFont.systemFontOfSize(15)
            self.menuView?.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(1)
            self.menuView!.menuViewDelegate = self
            fillView.addSubview(menuView!)

            // CVCalendarView initialization with frame
            self.calendarView = CVCalendarView(frame: CGRectMake(10, 60, UIScreen.mainScreen().bounds.size.width - 20, 220))
            self.calendarView?.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(1)
            calendarView?.hidden = false
            fillView.addSubview(calendarView!)
            self.calendarView!.calendarAppearanceDelegate = self
            self.calendarView!.animatorDelegate = self
            self.calendarView!.calendarDelegate = self

            // Commit frames' updates
            self.calendarView!.commitCalendarViewUpdate()
            self.menuView!.commitMenuViewUpdate()

            calendarView?.coordinator.selectedDayView?.selectionView?.shape = CVShape.Rect

            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                calendarBackGroundView.alpha = 1
            }) { (finish) in

            }

        }else {
            view?.hidden = false
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                view?.alpha = 1
            }) { (finish) in
            }
        }
    }

    /**
     Finish the selected calendar call
     */
    func dismissCalendar() {
        let view = self.view.viewWithTag(CALENDAR_VIEW_TAG)
        if(view != nil) {
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                view?.alpha = 0
            }) { (finish) in
                view?.hidden = true
            }
        }
    }

    /**
     Click on the calendar the blanks
     - parameter recognizer: recognizer description
     */
    func tapAction(recognizer:UITapGestureRecognizer) {
        self.dismissCalendar()
        titleView?.selectedFinishTitleView()
    }
}

// MARK: - CVCalendarViewDelegate, CVCalendarMenuViewDelegate
extension StepsViewController: CVCalendarViewDelegate, CVCalendarMenuViewDelegate {
    /// Required method to implement!
    func presentationMode() -> CalendarMode {
        return .MonthView
    }

    /// Required method to implement!
    func firstWeekday() -> Weekday {
        return .Sunday
    }

    func dayOfWeekTextUppercase() -> Bool {
        return false
    }
    // MARK: Optional methods
    func shouldShowWeekdaysOut() -> Bool {
        return false
    }

    func shouldAnimateResizing() -> Bool {
        return true // Default value is true
    }

    func shouldAutoSelectDayOnMonthChange() -> Bool {
        return false
    }
    
    func didSelectDayView(dayView: CVCalendarDayView, animationDidFinish: Bool) {
        print("\(dayView.date.commonDescription) is selected!")
        dayView.selectionView?.shape = CVShape.Rect
        self.dismissCalendar()
        titleView?.selectedFinishTitleView()
        
        /// No data for the selected date available.
        let dayDate:NSDate = dayView.date!.convertedDate()!
        let dayTime:NSTimeInterval = NSDate.date(year: dayDate.year, month: dayDate.month, day: dayDate.day, hour: 0, minute: 0, second: 0).timeIntervalSince1970
        self.bulidChart(NSDate(timeIntervalSince1970: dayTime))
        
    }

    func dotMarker(shouldShowOnDayView dayView: CVCalendarDayView) -> Bool {
        dayView.selectionView?.shape = CVShape.Rect
        return false
    }

    func dotMarker(shouldMoveOnHighlightingOnDayView dayView: CVCalendarDayView) -> Bool {
        dayView.selectionView?.shape = CVShape.Rect
        return true
    }

    func preliminaryView(shouldDisplayOnDayView dayView: DayView) -> Bool {
        dayView.selectionView?.shape = CVShape.Rect
        return false
    }

    func presentedDateUpdated(date: CVDate) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMM"
        let dateString = "\(formatter.stringFromDate(date.convertedDate()!)), \(date.day)"
        titleView?.setCalendarButtonTitle(dateString)
    }

    func topMarker(shouldDisplayOnDayView dayView: CVCalendarDayView) -> Bool {
        dayView.selectionView?.shape = CVShape.Rect
        return false
    }

    func weekdaySymbolType() -> WeekdaySymbolType {
        return .VeryShort
    }

    func shouldShowCustomSingleSelection() -> Bool {
        return false
    }
}

// MARK: - CVCalendarViewAppearanceDelegate
extension StepsViewController: CVCalendarViewAppearanceDelegate {
    func dayLabelPresentWeekdayInitallyBold() -> Bool {
        return false
    }

    func spaceBetweenDayViews() -> CGFloat {
        return 2
    }
    

    func dayLabelWeekdayInTextColor() -> UIColor {
        return UIColor(rgba: "#676767")
    }

    func dayLabelWeekdaySelectedBackgroundColor() -> UIColor {
        return UIColor(rgba: "#55028C")
    }
}
