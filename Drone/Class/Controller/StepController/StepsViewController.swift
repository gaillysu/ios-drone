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
        let yXaxis:ChartYAxis = barChart!.leftAxis;
        yXaxis.labelTextColor = UIColor.grayColor();
        yXaxis.axisLineColor = UIColor.grayColor();
        barChart!.rightAxis.enabled = false;
        barChart!.zoom(14, scaleY: 1, xIndex: 0, yValue: 0, axis: .Left);
        // 14 is hard coded, should be 100 / 14 = 7, no mather what 100 is, 7 must come out.
        xAxis.labelPosition = ChartXAxis.XAxisLabelPosition.Bottom
        let stepsArray: NSMutableArray = NSMutableArray();
        let now = NSDate();

        for j in 0 ..< 100 {
            let steps = Int(arc4random_uniform(6000) + 1000)
            let date:NSDate = now - j.day;
            stepsArray.addObject(UserSteps(keyDict:["id":j,"steps":steps,"distance":0,"date":(date.timeIntervalSince1970)]));
        }
        // Need to get some Goal somewhere arround, for now Goal is 10000
        let goal = 10000;
        let today:UserSteps = stepsArray[0] as! UserSteps
        let percentage = (Double(today.steps)/Double(goal)) * 100
        circleProgressView.setProgress(Double(today.steps)/Double(goal), animated: true)
        stepsLabel.text = String(format:"%d",today.steps)
        percentageLabel.text = String(format:"Goal: %d%",goal)
        
        barChart.drawBarShadowEnabled = false
        var xVals = [String]();
        var yVals = [ChartDataEntry]();
        
        for i in 0 ..< stepsArray.count {
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
            barChartSet.colors = [UIColor(rgba: "#66CCCC")]
            barChartSet.highlightColor = UIColor(rgba: "#66CCCC")
            barChartSet.valueColors = [UIColor.grayColor()]
            let barChartData = BarChartData(xVals: xVals, dataSet: barChartSet)
            self.barChart.data = barChartData;
        }
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
            fillView.backgroundColor = UIColor.init(colorLiteralRed: 36/255.0, green: 135/255.0, blue: 163/255.0, alpha: 1).colorWithAlphaComponent(1)
            calendarBackGroundView.addSubview(fillView)

            self.menuView = CVCalendarMenuView(frame: CGRectMake(10, 0, UIScreen.mainScreen().bounds.size.width - 20, 20))
            self.menuView?.dayOfWeekTextColor = UIColor.whiteColor()
            self.menuView?.backgroundColor = UIColor.init(colorLiteralRed: 36/255.0, green: 135/255.0, blue: 163/255.0, alpha: 1).colorWithAlphaComponent(1)
            self.menuView!.menuViewDelegate = self
            fillView.addSubview(menuView!)

            // CVCalendarView initialization with frame
            self.calendarView = CVCalendarView(frame: CGRectMake(10, 23, UIScreen.mainScreen().bounds.size.width - 20, 250))
            self.calendarView?.backgroundColor = UIColor.init(colorLiteralRed: 36/255.0, green: 135/255.0, blue: 163/255.0, alpha: 1).colorWithAlphaComponent(1)
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
        let day = dayView.date.day
        let randomDay = Int(arc4random_uniform(31))
        if day == randomDay {
            return true
        }

        return false
    }

    func dotMarker(colorOnDayView dayView: CVCalendarDayView) -> [UIColor] {

        let red = CGFloat(arc4random_uniform(600) / 255)
        let green = CGFloat(arc4random_uniform(600) / 255)
        let blue = CGFloat(arc4random_uniform(600) / 255)

        let color = UIColor(red: red, green: green, blue: blue, alpha: 1)

        let numberOfDots = Int(arc4random_uniform(3) + 1)
        switch(numberOfDots) {
        case 2:
            return [color, color]
        case 3:
            return [color, color, color]
        default:
            return [color] // return 1 dot
        }
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
        let circleView = CVAuxiliaryView(dayView: dayView, rect: dayView.bounds, shape: CVShape.Circle)
        circleView.fillColor = .colorFromCode(0xCCCCCC)
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
