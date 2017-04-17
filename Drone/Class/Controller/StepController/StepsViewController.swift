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
import UIColor_Hex_Swift
import CVCalendar
import SwiftEventBus
import MRProgress


let SMALL_SYNC_LASTDATA:String = "SMALL_SYNC_LASTDATA"
let IS_SEND_0X30_COMMAND:String = "IS_SEND_0X30_COMMAND"
let IS_SEND_0X14_COMMAND_TIMERFRAME:String = "IS_SEND_0X14_COMMAND_TIMERFRAME"

private let CALENDAR_VIEW_TAG = 1800
class StepsViewController: BaseViewController,UIActionSheetDelegate {
    
    @IBOutlet var mainview: UIView!
    @IBOutlet weak var circleProgressView: CircleProgressView!
    @IBOutlet weak var lastMiles: UILabel!
    @IBOutlet weak var lastCalories: UILabel!
    @IBOutlet weak var lastActiveTime: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    
    @IBOutlet weak var barChart: StepsBarChartView!
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
    lazy var goal: UserGoal = {
        if UserGoal.getAll().count > 0 {
            let userGoal:UserGoal = UserGoal.getAll().first as! UserGoal
            return userGoal
        }
        let userGoal:UserGoal = UserGoal()
        userGoal.goalSteps = 10000
        userGoal.label = " "
        userGoal.status = false
        _ = userGoal.add()
        return userGoal
    }()
    
    fileprivate var didSelectedDate:Date = Date()
    fileprivate var queryTimer:Timer?
    
    init() {
        super.init(nibName: "StepsViewController", bundle: Bundle.main)
        self.tabBarItem.title="Steps"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initTitleView()
        
        percentageLabel.text = String(format:"Goal: %d",(goal.goalSteps))
        self.navigationController?.navigationBar.backItem?.backBarButtonItem?.image = nil;
        stepsLabel.text = "0"
        
        self.getLoclSmallSyncData(nil)
        addCloseButton(#selector(dismissViewController))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Set Goal", style: .plain, target: self, action: #selector(setGoal))
    }
    
    func setGoal(){
        let alertController = UIAlertController(title: "Select your goal", message: "", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "7000", style: .default) { _ in
            
        })
        alertController.addAction(UIAlertAction(title: "10000", style: .default) { _ in
            
        })
        alertController.addAction(UIAlertAction(title: "20000", style: .default) { _ in
            
        })
        alertController.addAction(UIAlertAction(title: "Custom...", style: .default) { _ in
            
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            
        })
        present(alertController, animated: true, completion: nil)
    }
    
    func dismissViewController(){
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        _ = SwiftEventBus.onMainThread(self, name: SWIFTEVENT_BUS_SMALL_SYNCACTIVITY_DATA) { (notification) in
            if self.didSelectedDate.beginningOfDay == Date().beginningOfDay {
                let rawGoalPacket:StepsGoalPacket = notification.object as! StepsGoalPacket
                let saveData:[String:Any] = ["dailySteps":rawGoalPacket.getDailySteps(),"goal":rawGoalPacket.getGoal(),"date":Date()]
                _ = AppTheme.KeyedArchiverName(SMALL_SYNC_LASTDATA, andObject: saveData)
                self.getLoclSmallSyncData(saveData)
            }
        }
        
        _ = SwiftEventBus.onMainThread(self, name: SWIFTEVENT_BUS_BEGIN_BIG_SYNCACTIVITY) { (notification) in
            debugPrint("Data sync began")
            //release timer
            self.invalidateTimer()
        }
        
        _ = SwiftEventBus.onMainThread(self, name: SWIFTEVENT_BUS_END_BIG_SYNCACTIVITY) { (notification) in
            debugPrint("End of the data sync")
            //start small sync timer
            self.fireSmallSyncTimer()
            //refresh chart data
            self.bulidChart(Foundation.Date().beginningOfDay)
        }
        
        if let unwrappedData = AppTheme.LoadKeyedArchiverName(IS_SEND_0X30_COMMAND){
            let lastData:[String:Any] = unwrappedData as! [String:Any]
            let date:Date = lastData["date"] as! Date
            if date == Date().beginningOfDay {
                AppDelegate.getAppDelegate().setStepsToWatch()
            }
        }
        
        self.fireSmallSyncTimer()
        
        self.bulidChart(didSelectedDate)
    }
    
    func invalidateTimer() {
        if queryTimer == nil {
            return
        }
        if queryTimer!.isValid {
            queryTimer?.invalidate()
            queryTimer = nil
        }
    }
    
    func fireSmallSyncTimer() {
        if queryTimer == nil {
            self.queryTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.queryStepsGoalAction(_:)), userInfo: nil, repeats: true)
        }
    }
    
    func queryStepsGoalAction(_ timer:Timer) {
        if AppDelegate.getAppDelegate().syncState != SYNC_STATE.big_SYNC {
            AppDelegate.getAppDelegate().getGoal()
        }
        
        if let lastData = AppTheme.LoadKeyedArchiverName(IS_SEND_0X14_COMMAND_TIMERFRAME) as? NSArray{
            if lastData.count > 0 {
                let sendLastDate:Date = lastData[0] as! Date
                let nowDate:Date = Date()
                let fiveMinutes:TimeInterval = 300
                if (nowDate.timeIntervalSince1970-sendLastDate.timeIntervalSince1970)>=fiveMinutes {
                    _ = AppTheme.KeyedArchiverName(IS_SEND_0X14_COMMAND_TIMERFRAME, andObject: Date())
                    AppDelegate.getAppDelegate().getActivity()
                }
            }else{
                _ = AppTheme.KeyedArchiverName(IS_SEND_0X14_COMMAND_TIMERFRAME, andObject: Date())
                AppDelegate.getAppDelegate().getActivity()
            }
        }
    }
    
    func getLoclSmallSyncData(_ data:[String:Any]?){
        if let unpackeddata  = AppTheme.LoadKeyedArchiverName(SMALL_SYNC_LASTDATA){
            let stepsDict:[String:Any] = unpackeddata as! [String:Any]
            let smallDate = stepsDict["date"] as! Date
            let dailySteps:String = String(format: "%d", stepsDict["dailySteps"] as! Int)
            let stepsGoal:String = String(format: "%d", stepsDict["goal"] as! Int)
            
            if smallDate.beginningOfDay == Date().beginningOfDay {
                if let last0X30Data = AppTheme.LoadKeyedArchiverName(IS_SEND_0X30_COMMAND) {
                    let data:[String:Any] = last0X30Data as! [String:Any]
                    let date:Date = data["date"] as! Date
                    if date.beginningOfDay == Date().beginningOfDay {
                        DispatchQueue.main.async(execute: {
                            // do something
                            let steps:String =  String(format: "%@", data["steps"] as! Int)
                            let daySteps:Int = steps.toInt() + dailySteps.toInt()
                            self.setCircleProgress(daySteps, goalValue: stepsGoal.toInt())
                        })
                        
                    }else{
                        self.setCircleProgress(dailySteps.toInt() , goalValue: stepsGoal.toInt())
                    }
                }else{
                    self.setCircleProgress(dailySteps.toInt(), goalValue: stepsGoal.toInt())
                }
            }
        }
    }
}

extension StepsViewController {
    
    func setCircleProgress(_ stepsValue:Int,goalValue:Int) {
        circleProgressView.setProgress(Double(stepsValue)/Double(goalValue), animated: true)
        stepsLabel.text = String(format:"%d",stepsValue)
        
    }
    
    func bulidChart(_ todayDate:Foundation.Date) {
        lastWeekChart.reset()
        lastMonthChart.reset()
        thisWeekChart.reset()
        
        barChart.drawSettings(barChart.xAxis, yAxis: barChart.leftAxis, rightAxis: barChart.rightAxis)
        
        let lastValue = barChart.invalidateChart(date: todayDate)
        let lastSteps:Int = lastValue.lastSteps
        let lastTimeframe:Int = lastValue.lastTimeframe
        //display selected today steps data
        if didSelectedDate != Foundation.Date().beginningOfDay {
            self.setCircleProgress(lastSteps , goalValue: goal.goalSteps)
        }
        
        if lastSteps>0 {
            calculationData(lastTimeframe,steps: lastSteps, completionData: { (miles, calories) in
                self.lastMiles.text = miles
                self.lastCalories.text = calories
                let timer:String = String(format: "%.2f",Double(lastTimeframe)/60)
                let timerArray = timer.components(separatedBy: ".")
                if timerArray[0].toInt() > 0 {
                    self.lastActiveTime.text = "\(timerArray[0])h \(String(format: "%.0f",Double("0."+timerArray[1])!*60))m"
                }else{
                    self.lastActiveTime.text = "\(lastTimeframe)m"
                }
            })
        }else{
            self.lastMiles.text = "0"
            self.lastCalories.text = "0"
            self.lastActiveTime.text = "0m"
        }
        
        lastWeekChart.drawSettings(lastWeekChart.xAxis, yAxis: lastWeekChart.leftAxis, rightAxis: lastWeekChart.rightAxis)
        thisWeekChart.drawSettings(thisWeekChart.xAxis, yAxis: thisWeekChart.leftAxis, rightAxis: thisWeekChart.rightAxis)
        lastMonthChart.drawSettings(lastMonthChart.xAxis, yAxis: lastMonthChart.leftAxis, rightAxis: lastMonthChart.rightAxis)
        
        let oneWeekSeconds:Double = 604800
        let oneDaySeconds:Double  = 86400
        
        var thisWeekSteps:Int = 0
        var thisWeekTime:Int = 0
        for i in 0 ..< 7 {
            let dayTimeInterval:TimeInterval = todayDate.beginningOfWeek.timeIntervalSince1970+(oneDaySeconds*Double(i))
            let dayDate:Foundation.Date = Foundation.Date(timeIntervalSince1970: dayTimeInterval)
            let dayTime:TimeInterval = Foundation.Date.date(year: dayDate.year, month: dayDate.month, day: dayDate.day, hour: 0, minute: 0, second: 0).timeIntervalSince1970
            let hours = UserSteps.getFilter("date >= \(dayTime) AND date <= \(dayTime+oneDaySeconds-1)")
            var hourData:Double = 0
            for userSteps in hours {
                let hSteps:UserSteps = userSteps as! UserSteps
                hourData += Double(hSteps.steps)
                if hSteps.steps>0 {
                    thisWeekTime+=5
                }
            }
            thisWeekSteps+=Int(hourData)
            let formatter = DateFormatter()
            formatter.dateFormat = "M/dd"
            let dateString = "\(formatter.string(from: dayDate))"
            thisWeekChart.addDataPoint("\(dateString)", entry: BarChartDataEntry(x:Double(i) ,y: hourData))
        }
        
        if thisWeekSteps>0 {
            calculationData(thisWeekTime,steps: thisWeekSteps, completionData: { (miles, calories) in
                self.thisWeekMiles.text = miles
                self.thisWeekCalories.text = calories
                let timer:String = String(format: "%.2f",Double(thisWeekTime)/60)
                let timerArray = timer.components(separatedBy: ".")
                if timerArray[0].toInt()>0 {
                    self.thisWeekActiveTime.text = "\(timerArray[0])h \(String(format: "%.0f",Double("0."+timerArray[1])!*60))m"
                }else{
                    self.thisWeekActiveTime.text = "\(timerArray[1])m"
                }
            })
        }else{
            self.thisWeekMiles.text = "0"
            self.thisWeekCalories.text = "0"
            self.thisWeekActiveTime.text = "0m"
        }
        
        var lastWeekSteps:Int = 0
        var lastWeekTime:Int = 0
        let beginningOfWeek:TimeInterval = todayDate.beginningOfWeek.timeIntervalSince1970
        for i in 0 ..< 7 {
            let dayTimeInterval:TimeInterval = (beginningOfWeek+(oneDaySeconds*Double(i)))-oneWeekSeconds
            let dayDate:Date = Date(timeIntervalSince1970: dayTimeInterval)
            let hours = UserSteps.getFilter("date >= \(dayDate.beginningOfDay.timeIntervalSince1970) AND date <= \(dayDate.endOfDay.timeIntervalSince1970)")
            var hourData:Double = 0
            for userSteps in hours {
                let hSteps:UserSteps = userSteps as! UserSteps
                hourData += Double(hSteps.steps)
                if hSteps.steps>0 {
                    lastWeekTime+=5
                }
            }
            lastWeekSteps+=Int(hourData)
            
            let dateString = dayDate.stringFromFormat("M/dd")
            lastWeekChart.addDataPoint("\(dateString)", entry: BarChartDataEntry(x:Double(i), y: hourData))
        }
        
        if lastWeekSteps>0 {
            calculationData(lastWeekTime,steps: lastWeekSteps, completionData: { (miles, calories) in
                self.lastWeekMiles.text = miles
                self.lastWeekCalories.text = calories
                let timer:String = String(format: "%.2f",Double(lastWeekTime)/60)
                let timerArray = timer.components(separatedBy: ".")
                if timerArray[0].toInt()>0 {
                    self.lastWeekActiveTime.text = "\(timerArray[0])h \(String(format: "%.0f",Double("0."+timerArray[1])!*60))m"
                }else{
                    self.lastWeekActiveTime.text = "\(timerArray[1])m"
                }
            })
        }else{
            self.lastWeekMiles.text = "0"
            self.lastWeekCalories.text = "0"
            self.lastWeekActiveTime.text = "0m"
        }
        
        let lastBeginningOfMonth:TimeInterval = todayDate.beginningOfDay.timeIntervalSince1970
        
        var lastMonthSteps:Int = 0
        var lastMonthTime:Int = 0
        for i in 0 ..< 30 {
            let monthTimeInterval:TimeInterval = lastBeginningOfMonth-oneDaySeconds*Double(i)
            let hours = UserSteps.getFilter("date >= \(monthTimeInterval)  AND date <= \(monthTimeInterval+oneDaySeconds-1)")
            var hourData:Double = 0
            for userSteps in hours {
                let hSteps:UserSteps = userSteps as! UserSteps
                hourData += Double(hSteps.steps)
                if hSteps.steps>0 {
                    lastMonthTime+=5
                }
            }
            lastMonthSteps+=Int(hourData)
            let formatter = DateFormatter()
            formatter.dateFormat = "M/dd"
            let dateString = "\(formatter.string(from: Foundation.Date(timeIntervalSince1970: monthTimeInterval)))"
            
            lastMonthChart.addDataPoint("\(dateString)", entry: BarChartDataEntry(x: Double(i), y: hourData))
        }
        
        if lastMonthSteps>0 {
            calculationData(lastMonthTime,steps: lastMonthSteps, completionData: { (miles, calories) in
                self.lastMonthMiles.text = miles
                self.lastMonthCalories.text = calories
                let timer:String = String(format: "%.2f",Double(lastMonthTime)/60)
                let timerArray = timer.components(separatedBy: ".")
                if timerArray[0].toInt() > 0 {
                    self.lastMonthActiveTime.text = "\(timerArray[0])h \(String(format: "%.0f",Double("0."+timerArray[1])!*60))m"
                }else{
                    self.lastMonthActiveTime.text = "\(timerArray[1])m"
                }
            })
        }else{
            self.lastMonthMiles.text = "0"
            self.lastMonthCalories.text = "0"
            self.lastMonthActiveTime.text = "0m"
        }
        
        lastWeekChart.invalidateChart()
        thisWeekChart.invalidateChart()
        lastMonthChart.invalidateChart()
    }
}

// MARK: - Data calculation
//extension StepsViewController {

extension StepsViewController {
    
    func calculationData(_ activeTimer:Int,steps:Int,completionData:((_ miles:String,_ calories:String) -> Void)) {
        let profile = UserProfile.getAll()
        if(profile.count > 0){
            let userProfile:UserProfile = profile.first as! UserProfile
            let strideLength:Double = Double(userProfile.length)*0.415/100
            let miles:Double = strideLength*Double(steps)/1000
            //Formula's = (2.0 X persons KG X 3.5)/200 = calories per minute
            let calories:Double = (2.0*Double(userProfile.weight)*3.5)/200*Double(activeTimer)
            completionData(String(format: "%.2f",miles), String(format: "%.2f",calories))
        }
    }
}

// MARK: - Title View
extension StepsViewController {
    
    func initTitleView() {
        titleView = StepsTitleView.getStepsTitleView(CGRect(x: 0,y: 0,width: 190,height: 50))
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        let dateString = "\(formatter.string(from: Foundation.Date())), \(Foundation.Date().day)"
        titleView?.setCalendarButtonTitle(dateString)
        self.navigationItem.titleView = titleView
        titleView!.buttonResultHandler = { result -> Void in
            let clickButton:UIButton = result as! UIButton
            if (result!.isEqual(self.titleView!.calendarButton) && clickButton.isSelected) {
                self.showCalendar()
            }else if (result!.isEqual(self.titleView!.calendarButton) && !clickButton.isSelected) {
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
            let calendarBackGroundView:UIView = UIView(frame: CGRect(x: 0,y: 0,width: UIScreen.main.bounds.size.width,height: self.view.frame.size.height))
            calendarBackGroundView.alpha = 0
            calendarBackGroundView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            calendarBackGroundView.tag = CALENDAR_VIEW_TAG
            let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(StepsViewController.tapAction(_:)))
            calendarBackGroundView.addGestureRecognizer(tap)
            self.view.addSubview(calendarBackGroundView)
            
            let fillView:UIView = UIView(frame: CGRect(x: 0,y: 0,width: UIScreen.main.bounds.size.width,height: 280))
            fillView.backgroundColor = UIColor.white.withAlphaComponent(1)
            calendarBackGroundView.addSubview(fillView)
            
            self.menuView = CVCalendarMenuView(frame: CGRect(x: 10, y: 40, width: UIScreen.main.bounds.size.width - 20, height: 20))
            self.menuView?.dayOfWeekTextColor = UIColor.white
            self.menuView?.dayOfWeekTextColor = UIColor.gray
            self.menuView?.dayOfWeekFont = UIFont.systemFont(ofSize: 15)
            self.menuView?.backgroundColor = UIColor.white.withAlphaComponent(1)
            self.menuView!.menuViewDelegate = self
            fillView.addSubview(menuView!)
            
            // CVCalendarView initialization with frame
            self.calendarView = CVCalendarView(frame: CGRect(x: 10, y: 60, width: UIScreen.main.bounds.size.width - 20, height: 220))
            self.calendarView?.backgroundColor = UIColor.white.withAlphaComponent(1)
            calendarView?.isHidden = false
            fillView.addSubview(calendarView!)
            self.calendarView!.calendarAppearanceDelegate = self
            self.calendarView!.animatorDelegate = self
            self.calendarView!.calendarDelegate = self
            
            // Commit frames' updates
            self.calendarView!.commitCalendarViewUpdate()
            self.menuView!.commitMenuViewUpdate()
            
            calendarView?.coordinator.selectedDayView?.selectionView?.shape = CVShape.rect
            
            UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                calendarBackGroundView.alpha = 1
            }) { (finish) in
                
            }
            
        }else {
            view?.isHidden = false
            UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                view?.alpha = 1
            }) { (finish) in
            }
        }
    }
    
    func dismissCalendar() {
        let view = self.view.viewWithTag(CALENDAR_VIEW_TAG)
        if(view != nil) {
            UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                view?.alpha = 0
            }) { (finish) in
                view?.isHidden = true
            }
        }
    }
    
    func tapAction(_ recognizer:UITapGestureRecognizer) {
        self.dismissCalendar()
        titleView?.selectedFinishTitleView()
    }
    
}

// MARK: - CVCalendarViewDelegate, CVCalendarMenuViewDelegate
extension StepsViewController: CVCalendarViewDelegate, CVCalendarMenuViewDelegate {
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    /// Required method to implement!
    func presentationMode() -> CalendarMode {
        return .monthView
    }
    
    /// Required method to implement!
    func firstWeekday() -> Weekday {
        return .sunday
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
    
    func didSelectDayView(_ dayView: CVCalendarDayView, animationDidFinish: Bool) {
        dayView.selectionView?.shape = CVShape.rect
        self.dismissCalendar()
        titleView?.selectedFinishTitleView()
        
        /// No data for the selected date available.
        
        let dayDate:Foundation.Date = dayView.date!.convertedDate(calendar: Calendar.current)!
        let dayTime:TimeInterval = Foundation.Date.date(year: dayDate.year, month: dayDate.month, day: dayDate.day, hour: 0, minute: 0, second: 0).timeIntervalSince1970
        didSelectedDate = Foundation.Date(timeIntervalSince1970: dayTime)
        
        self.bulidChart(Foundation.Date(timeIntervalSince1970: dayTime))
        let hours = UserSteps.getFilter("date >= \(dayDate.beginningOfDay.timeIntervalSince1970) AND date <= \(dayDate.endOfDay.timeIntervalSince1970)")
        if hours.count == 0 {
            let view = MRProgressOverlayView.showOverlayAdded(to: self.navigationController!.view, title: "Please wait...", mode: MRProgressOverlayViewMode.indeterminate, animated: true)
            view?.setTintColor(UIColor.getBaseColor())
            let startDate = didSelectedDate
            let profile = UserProfile.getAll()
            if let userProfile:UserProfile = profile.first as? UserProfile{
                StepsNetworkManager.stepsForDate(uid: userProfile.id, date: startDate, completion: { result in
                    MRProgressOverlayView.dismissAllOverlays(for: self.navigationController!.view, animated: true)
                    self.delay(0.3, closure: {
                        self.bulidChart(Foundation.Date(timeIntervalSince1970: dayTime))
                        AppDelegate.getAppDelegate().setStepsToWatch()
                    })
                })
            }
        }
    }
    
    func dotMarker(shouldShowOnDayView dayView: CVCalendarDayView) -> Bool {
        dayView.selectionView?.shape = CVShape.rect
        return false
    }
    
    func dotMarker(shouldMoveOnHighlightingOnDayView dayView: CVCalendarDayView) -> Bool {
        dayView.selectionView?.shape = CVShape.rect
        return true
    }
    
    func preliminaryView(shouldDisplayOnDayView dayView: DayView) -> Bool {
        dayView.selectionView?.shape = CVShape.rect
        return false
    }
    
    func presentedDateUpdated(_ date: CVDate) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        let dateString = "\(formatter.string(from: date.convertedDate(calendar: Calendar.current)!)), \(date.day)"
        titleView?.setCalendarButtonTitle(dateString)
    }
    
    func topMarker(shouldDisplayOnDayView dayView: CVCalendarDayView) -> Bool {
        dayView.selectionView?.shape = CVShape.rect
        return false
    }
    
    func weekdaySymbolType() -> WeekdaySymbolType {
        return .veryShort
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
        return UIColor("#676767")
    }
    
    func dayLabelWeekdaySelectedBackgroundColor() -> UIColor {
        return UIColor("#55028C")
    }
}
