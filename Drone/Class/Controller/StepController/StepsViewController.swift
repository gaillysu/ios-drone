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

let NUMBER_OF_STEPS_GOAL_KEY = "NUMBER_OF_STEPS_GOAL_KEY"

private let CALENDAR_VIEW_TAG = 1800
class StepsViewController: BaseViewController,UIActionSheetDelegate {

    @IBOutlet var mainview: UIView!
    @IBOutlet weak var circleProgressView: CircleProgressView!
    // TODO eventbus: Steps, small & big sync
    @IBOutlet weak var stepsLabel: UILabel!
    
    @IBOutlet weak var barChart: BarChartView!
    @IBOutlet weak var percentageLabel: UILabel!

    var shouldShowDaysOut = true
    var animationFinished = true
    var selectedDay:DayView?
    var calendarView:CVCalendarView?
    var menuView:CVCalendarMenuView?
    var titleView:StepsTitleView?

    init() {
        super.init(nibName: "StepsViewController", bundle: NSBundle.mainBundle())
        self.tabBarItem.title="Steps"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "gradually"), forBarMetrics: UIBarMetrics.Default)
        self.initTitleView()
        self.navigationController?.navigationBar.backItem?.backBarButtonItem?.image = nil;
    }

    override func viewWillAppear(animated: Bool) {
        
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
        yAxis.customAxisMin = 0;
        yAxis.drawZeroLineEnabled = false;
      
        barChart!.rightAxis.enabled = false;
        let stepsArray: NSMutableArray = NSMutableArray();
        let now = NSDate();
        var mostSteps = 0;
        for j in 0 ..< 25 {
            let steps = Int(arc4random_uniform(4000))
            if(mostSteps < steps){
                mostSteps = steps
            }
            let date:NSDate = now - j.day;
            stepsArray.addObject(UserSteps(keyDict:["id":j,"steps":steps,"distance":0,"date":(date.timeIntervalSince1970)]));
        }
        if(mostSteps > 1000){
            let remainingTillThousand = abs(1000 - (mostSteps % 1000));
            let max = Double(mostSteps) + Double(remainingTillThousand)
            yAxis.customAxisMax = max
            if(max % 1000 == 0){
                yAxis.setLabelCount((Int(max)/1000) + 1, force: true);
            }else{
                yAxis.setLabelCount((Int(max)/1000), force: true);
            }
        }else{
            let remainingTillThousand = abs(100 - (mostSteps % 100));
            let max = Double(mostSteps) + Double(remainingTillThousand)
            yAxis.customAxisMax = max
            if(max % 100 == 0){
                yAxis.setLabelCount((Int(max)/100) + 1, force: true);
            }else{
                yAxis.setLabelCount((Int(max)/100), force: true);
            }
        }
        
        let goal = 10000;
        let today:UserSteps = stepsArray[0] as! UserSteps
        circleProgressView.setProgress(Double(today.steps)/Double(goal), animated: true)
        
        stepsLabel.text = String(format:"%d",today.steps)
        percentageLabel.text = String(format:"Goal: %d%",goal)
        
        barChart.drawBarShadowEnabled = false
        var xVals = [String]();
        var yVals = [ChartDataEntry]();
        
        for i in 0 ..< stepsArray.count {
            let steps:UserSteps = stepsArray[i] as! UserSteps
            yVals.append(BarChartDataEntry(value: Double(steps.steps), xIndex:i));
            if(i == 0 || i == 6 || i == 12 || i == 18 || i == 24){
                xVals.append("\(i):00");
            }else{
                xVals.append("");
            }
            let barChartSet:BarChartDataSet = BarChartDataSet(yVals: yVals, label: "Steps")
            let dataSet = NSMutableArray()
            dataSet.addObject(barChartSet);
            barChartSet.colors = [UIColor(rgba: "#D19D42")]
            barChartSet.highlightColor = UIColor(rgba: "#D19D42")
            barChartSet.valueColors = [UIColor.grayColor()]
            let barChartData = BarChartData(xVals: xVals, dataSet: barChartSet)
            barChartData.setDrawValues(false);
            self.barChart.data = barChartData;
        }
        barChart?.animate(yAxisDuration: 2.0, easingOption: ChartEasingOption.EaseInOutCirc)
    }
    


}

// MARK: - Title View
extension StepsViewController {

    func initTitleView() {
        titleView = StepsTitleView.getStepsTitleView(CGRectMake(0,0,190,50))
        titleView?.setCalendarButtonTitle(CVDate(date: NSDate()).globalDescription)
        self.navigationItem.titleView = titleView
        titleView!.buttonResultHandler = { result -> Void in
            NSLog("selected title button")
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
            calendarBackGroundView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
            calendarBackGroundView.tag = CALENDAR_VIEW_TAG
            
            
            let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(StepsViewController.tapAction(_:)))
            calendarBackGroundView.addGestureRecognizer(tap)
            self.view.addSubview(calendarBackGroundView)

            let fillView:UIView = UIView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,275))
            fillView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(1)
            calendarBackGroundView.addSubview(fillView)

            self.menuView = CVCalendarMenuView(frame: CGRectMake(10, 0, UIScreen.mainScreen().bounds.size.width - 20, 20))
            self.menuView?.dayOfWeekTextColor = UIColor.whiteColor()
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
        }else {
            view?.hidden = false
            UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
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
            UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                view?.alpha = 0
            }) { (finish) in
                view?.hidden = true
            }
        }
    }

    /**
     Click on the calendar the blanks
     - parameter recognizer: <#recognizer description#>
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

    // MARK: Optional methods
    func shouldShowWeekdaysOut() -> Bool {
        return shouldShowDaysOut
    }

    func shouldAnimateResizing() -> Bool {
        return true // Default value is true
    }

    func didSelectDayView(dayView: CVCalendarDayView, animationDidFinish: Bool) {
        print("\(dayView.date.commonDescription) is selected!")
        selectedDay = dayView
        
    }

    func presentedDateUpdated(date: CVDate) {
        titleView?.setCalendarButtonTitle(date.globalDescription)
    }

    func topMarker(shouldDisplayOnDayView dayView: CVCalendarDayView) -> Bool {
        return true
    }

    func dotMarker(shouldShowOnDayView dayView: CVCalendarDayView) -> Bool {

        return false
    }

    func dotMarker(shouldMoveOnHighlightingOnDayView dayView: CVCalendarDayView) -> Bool {
        return true
    }

    func dotMarker(sizeOnDayView dayView: DayView) -> CGFloat {
        return 13
    }

    func weekdaySymbolType() -> WeekdaySymbolType {
        return .Short
    }

    func selectionViewPath() -> ((CGRect) -> (UIBezierPath)) {
        return { UIBezierPath(rect: CGRectMake(0, 0, $0.width, $0.height)) }
    }

    func shouldShowCustomSingleSelection() -> Bool {
        return false
    }

    func preliminaryView(viewOnDayView dayView: DayView) -> UIView {
        let circleView = CVAuxiliaryView(dayView: dayView, rect: dayView.bounds, shape: CVShape.Rect)
        circleView.fillColor = .colorFromCode(0x552582)
        return circleView
    }

    func preliminaryView(shouldDisplayOnDayView dayView: DayView) -> Bool {
        if (dayView.isCurrentDay) {
            return true
        }
        return false
    }

    func supplementaryView(shouldDisplayOnDayView dayView: DayView) -> Bool {
        if (Int(arc4random_uniform(3)) == 1) {
            return true
        }

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
}
