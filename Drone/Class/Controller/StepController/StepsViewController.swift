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


let NUMBER_OF_STEPS_GOAL_KEY = "NUMBER_OF_STEPS_GOAL_KEY"

private let CALENDAR_VIEW_TAG = 1800
class StepsViewController: BaseViewController,UIActionSheetDelegate {

    @IBOutlet var mainview: UIView!
    @IBOutlet weak var circleProgressView: CircleProgressView!
    // TODO eventbus: Steps, small & big sync
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
    
    var shouldShowDaysOut = true
    var animationFinished = true
    var calendarView:CVCalendarView?
    var menuView:CVCalendarMenuView?
    var titleView:StepsTitleView?
    private var stepsArray:NSArray?
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
        let goal:GoalModel = GoalModel.getAll()[0] as! GoalModel
        percentageLabel.text = String(format:"Goal: %d",goal.goalSteps)
        self.navigationController?.navigationBar.backItem?.backBarButtonItem?.image = nil;
        stepsLabel.text = "0"
        
        SwiftEventBus.onMainThread(self, name: SWIFTEVENT_BUS_SMALL_SYNCACTIVITY_DATA) { (notification) in
            let stepsDict:[String:Int] = notification.object as! [String:Int]
            self.setCircleProgress(stepsDict["dailySteps"]! , goalValue: stepsDict["goal"]!)
        }

        let timerInter:NSTimeInterval = NSDate.today().timeIntervalSince1970
        stepsArray = UserSteps.getCriteria("WHERE date >= \(timerInter)")

        queryTimer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: #selector(StepsViewController.queryStepsGoalAction(_:)), userInfo: nil, repeats: true)
    }

    override func viewWillAppear(animated: Bool) {
        self.bulidChart()
    }

    override func viewDidDisappear(animated: Bool) {
        lastWeekChart.reset()
        lastMonthChart.reset()
        thisWeekChart.reset()

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

    func bulidChart() {

        barChart!.noDataText = "No History Available."
        barChart!.descriptionText = "";
        barChart!.pinchZoomEnabled = false
        barChart!.doubleTapToZoomEnabled = false;
        barChart!.legend.enabled = false;
        barChart!.dragEnabled = true
        let xAxis:ChartXAxis = barChart!.xAxis;
        xAxis.labelTextColor = UIColor.grayColor();
        xAxis.axisLineColor = UIColor.grayColor();
        xAxis.drawAxisLineEnabled = false;
        xAxis.drawGridLinesEnabled = false;
        xAxis.labelPosition = ChartXAxis.XAxisLabelPosition.Bottom

        let yAxis:ChartYAxis = barChart!.leftAxis;
        yAxis.labelTextColor = UIColor.grayColor();
        yAxis.axisLineColor = UIColor.clearColor();
        let goal:GoalModel = GoalModel.getAll()[0] as! GoalModel
        let max = goal.goalSteps/5
        yAxis.customAxisMax = Double(max)
        yAxis.customAxisMin = 0
        if(max % 500 == 0){
            yAxis.setLabelCount((Int(max)/500)+1, force: true);
        }else{
            yAxis.setLabelCount((Int(max)/500), force: true);
        }

        barChart!.rightAxis.enabled = false
        barChart.drawBarShadowEnabled = false
        var xVals = [String]();
        var yVals = [ChartDataEntry]();

        for i in 0 ..< 24 {
            let dayDate:NSDate = NSDate()
            
            let dayTime:NSTimeInterval = NSDate.date(year: dayDate.year, month: dayDate.month, day: dayDate.day, hour: i, minute: 0, second: 0).timeIntervalSince1970
            let hours:NSArray = UserSteps.getCriteria("WHERE date BETWEEN \(dayTime) AND \(dayTime+3600)") //one hour = 3600s
            
            var hourData:Double = 0
            for userSteps in hours {
                let hSteps:UserSteps = userSteps as! UserSteps
                hourData += Double(hSteps.steps)
            }
            yVals.append(BarChartDataEntry(value: hourData, xIndex:i));
            
            if(i%6 == 0){
                xVals.append("\(i):00");
            }else if(i == 23) {
                xVals.append("\(i+1):00");
            }else{
                xVals.append("");
            }

            let barChartSet:BarChartDataSet = BarChartDataSet(yVals: yVals, label: "Steps")
            let dataSet = NSMutableArray()
            dataSet.addObject(barChartSet);
            barChartSet.colors = [UIColor.getBaseColor()]
            barChartSet.highlightColor = UIColor.getBaseColor()
            barChartSet.valueColors = [UIColor.getGreyColor()]
            let barChartData = BarChartData(xVals: xVals, dataSet: barChartSet)
            barChartData.setDrawValues(false);
            self.barChart.data = barChartData;
        }
        
        barChart?.animate(yAxisDuration: 2.0, easingOption: ChartEasingOption.EaseInOutCirc)
        lastWeekChart.drawSettings(lastWeekChart.xAxis, yAxis: lastWeekChart.leftAxis, rightAxis: lastWeekChart.rightAxis)
        thisWeekChart.drawSettings(thisWeekChart.xAxis, yAxis: thisWeekChart.leftAxis, rightAxis: thisWeekChart.rightAxis)
        lastMonthChart.drawSettings(lastMonthChart.xAxis, yAxis: lastMonthChart.leftAxis, rightAxis: lastMonthChart.rightAxis)

        let oneWeekSeconds:Double = 604800
        let oneDaySeconds:Double = 86400
        for i in 0 ..< 7 {
            let dayTimeInterval:NSTimeInterval = NSDate().beginningOfWeek.timeIntervalSince1970+(oneDaySeconds*Double(i))
            let dayDate:NSDate = NSDate(timeIntervalSince1970: dayTimeInterval)
            let dayTime:NSTimeInterval = NSDate.date(year: dayDate.year, month: dayDate.month, day: dayDate.day, hour: 0, minute: 0, second: 0).timeIntervalSince1970
            let hours:NSArray = UserSteps.getCriteria("WHERE date BETWEEN \(dayTime) AND \(dayTime+oneDaySeconds-1)")
            var hourData:Double = 0
            for userSteps in hours {
                let hSteps:UserSteps = userSteps as! UserSteps
                hourData += Double(hSteps.steps)
            }
            
            let formatter = NSDateFormatter()
            formatter.dateFormat = "MMMM"
            let dateString = "\(formatter.stringFromDate(dayDate)), \(dayDate.day)"
            thisWeekChart.addDataPoint("\(dateString)", entry: BarChartDataEntry(value: hourData, xIndex:i))
        }

        for i in 0 ..< 7 {
            let dayTimeInterval:NSTimeInterval = NSDate().beginningOfWeek.timeIntervalSince1970+(oneDaySeconds*Double(i))-oneWeekSeconds
            let dayDate:NSDate = NSDate(timeIntervalSince1970: dayTimeInterval)
            let dayTime:NSTimeInterval = NSDate.date(year: dayDate.year, month: dayDate.month, day: dayDate.day, hour: 0, minute: 0, second: 0).timeIntervalSince1970
            let hours:NSArray = UserSteps.getCriteria("WHERE date BETWEEN \(dayTime) AND \(dayTime+oneDaySeconds-1)")
            var hourData:Double = 0
            for userSteps in hours {
                let hSteps:UserSteps = userSteps as! UserSteps
                hourData += Double(hSteps.steps)
            }
            
            let formatter = NSDateFormatter()
            formatter.dateFormat = "MMMM"
            let dateString = "\(formatter.stringFromDate(dayDate)), \(dayDate.day)"
            
            lastWeekChart.addDataPoint("\(dateString)", entry: BarChartDataEntry(value: hourData, xIndex:i))
        }
        
        let lastEndOfMonth:NSTimeInterval = NSDate.date(year: NSDate().year, month: NSDate().month, day: 1).timeIntervalSince1970-oneDaySeconds
        let lastBeginningOfMonth:NSTimeInterval = NSDate.date(year: NSDate().year, month: NSDate(timeIntervalSince1970: lastEndOfMonth).month, day: 1).timeIntervalSince1970
        
        for i in 0 ..< 30 {
            let monthTimeInterval:NSTimeInterval = lastBeginningOfMonth+oneDaySeconds*Double(i)
            let hours:NSArray = UserSteps.getCriteria("WHERE date BETWEEN \(monthTimeInterval) AND \(monthTimeInterval+oneDaySeconds-1)")
            var hourData:Double = 0
            for userSteps in hours {
                let hSteps:UserSteps = userSteps as! UserSteps
                hourData += Double(hSteps.steps)
            }
            
            let formatter = NSDateFormatter()
            formatter.dateFormat = "MMMM"
            let dateString = "\(formatter.stringFromDate(NSDate(timeIntervalSince1970: monthTimeInterval))), \(NSDate(timeIntervalSince1970: monthTimeInterval).day)"
            
            lastMonthChart.addDataPoint("\(dateString)", entry: BarChartDataEntry(value: hourData, xIndex:i))
        }
        
        lastWeekChart.invalidateChart()
        thisWeekChart.invalidateChart()
        lastMonthChart.invalidateChart()
    }
}

// MARK: - Title View
extension StepsViewController {

    func initTitleView() {
        titleView = StepsTitleView.getStepsTitleView(CGRectMake(0,0,190,50))
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMMM"
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

            let fillView:UIView = UIView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,275))
            fillView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(1)
            calendarBackGroundView.addSubview(fillView)

            self.menuView = CVCalendarMenuView(frame: CGRectMake(10, 0, UIScreen.mainScreen().bounds.size.width - 20, 20))
            self.menuView?.dayOfWeekTextColor = UIColor.whiteColor()
            self.menuView?.dayOfWeekTextColor = UIColor.grayColor()
            self.menuView?.dayOfWeekFont = UIFont.systemFontOfSize(15)
            self.menuView?.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(1)
            self.menuView!.menuViewDelegate = self
            fillView.addSubview(menuView!)

            // CVCalendarView initialization with frame
            self.calendarView = CVCalendarView(frame: CGRectMake(10, 23, UIScreen.mainScreen().bounds.size.width - 20, 250))
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

    func didSelectDayView(dayView: CVCalendarDayView, animationDidFinish: Bool) {
        print("\(dayView.date.commonDescription) is selected!")
        dayView.selectionView?.shape = CVShape.Rect
        self.dismissCalendar()
        titleView?.selectedFinishTitleView()
        
        var xVals = [String]();
        var yVals = [ChartDataEntry]();
        
        for i in 0 ..< 24 {
            let dayDate:NSDate = dayView.date!.convertedDate()!
            let dayTime:NSTimeInterval = NSDate.date(year: dayDate.year, month: dayDate.month, day: dayDate.day, hour: i, minute: 0, second: 0).timeIntervalSince1970
            let hours:NSArray = UserSteps.getCriteria("WHERE date BETWEEN \(dayTime) AND \(dayTime+3600)") //one hour = 3600s
            
            var hourData:Double = 0
            for userSteps in hours {
                let hSteps:UserSteps = userSteps as! UserSteps
                hourData += Double(hSteps.steps)
            }
            yVals.append(BarChartDataEntry(value: hourData, xIndex:i));
            
            if(i%6 == 0){
                xVals.append("\(i):00");
            }else if(i == 23) {
                xVals.append("\(i+1):00");
            }else{
                xVals.append("");
            }
            
            let barChartSet:BarChartDataSet = BarChartDataSet(yVals: yVals, label: "Steps")
            let dataSet = NSMutableArray()
            dataSet.addObject(barChartSet);
            barChartSet.colors = [UIColor.getBaseColor()]
            barChartSet.highlightColor = UIColor.getBaseColor()
            barChartSet.valueColors = [UIColor.getGreyColor()]
            let barChartData = BarChartData(xVals: xVals, dataSet: barChartSet)
            barChartData.setDrawValues(false);
            self.barChart.data = barChartData;
        }
        
        barChart?.animate(yAxisDuration: 2.0, easingOption: ChartEasingOption.EaseInOutCirc)
        
    }

    func dotMarker(shouldShowOnDayView dayView: CVCalendarDayView) -> Bool {
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
        formatter.dateFormat = "MMMM"
        let dateString = "\(formatter.stringFromDate(date.convertedDate()!)), \(date.day)"
        titleView?.setCalendarButtonTitle(dateString)
    }

    func topMarker(shouldDisplayOnDayView dayView: CVCalendarDayView) -> Bool {
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
