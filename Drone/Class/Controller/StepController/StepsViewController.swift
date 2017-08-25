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
import RealmSwift
import Timepiece

let SMALL_SYNC_LASTDATA:String = "SMALL_SYNC_LASTDATA"
let IS_SEND_0X30_COMMAND:String = "IS_SEND_0X30_COMMAND"
let IS_SEND_0X14_COMMAND_TIMERFRAME:String = "IS_SEND_0X14_COMMAND_TIMERFRAME"

private let CALENDAR_VIEW_TAG = 1800
class StepsViewController: BaseViewController,UIActionSheetDelegate {
    
    @IBOutlet weak var mainview: UIView!
    @IBOutlet weak var circleProgressView: CircleProgressView!
    @IBOutlet weak var lastMiles: UILabel!
    @IBOutlet weak var lastCalories: UILabel!
    @IBOutlet weak var lastActiveTime: UILabel!
    @IBOutlet weak var stepsButton: UIButton!
    @IBOutlet weak var backgroundImage: UIImageView!
    
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
        _ = userGoal.add()
        return userGoal
    }()
    
    var lastSyncedSteps:Int = 0
    
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
        
        let imagePath:String = Bundle.main.path(forResource: "background_steps", ofType: "png")!
        if let imageValue = UIImage(contentsOfFile: imagePath) {
            backgroundImage.image = imageValue
        }
        
        self.initTitleView()
        percentageLabel.text = String(format:"Goal: %d",(goal.goalSteps))
        self.navigationController?.navigationBar.backItem?.backBarButtonItem?.image = nil;
        stepsButton.setTitle(String(format:"%d",0), for: .normal)
        self.getLoclSmallSyncData()
        addCloseButton(#selector(dismissViewController))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Set Goal", style: .plain, target: self, action: #selector(setGoal))
    }
    @IBAction func stepsButtonAction(_ sender: Any) {
        AppDelegate.getAppDelegate().getGoal()
    }
    
    func setGoal(){
        let alertController = UIAlertController(title: "Select your goal", message: "", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "7000", style: .default) { _ in
            self.updateGoal(steps: 7000)
        })
        alertController.addAction(UIAlertAction(title: "10000", style: .default) { _ in
            self.updateGoal(steps: 10000)
        })
        alertController.addAction(UIAlertAction(title: "20000", style: .default) { _ in
            self.updateGoal(steps: 20000)
        })
        alertController.addAction(UIAlertAction(title: "Custom...", style: .default) { _ in
            let customGoalAlertController = UIAlertController(title: "Goal", message: "Set your custom goal.", preferredStyle: .alert)
            customGoalAlertController.addTextField(configurationHandler: { textfield in
                textfield.keyboardType = .numberPad
            })
            customGoalAlertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                guard let text = (customGoalAlertController.textFields?.first?.text) else {
                    return
                }
                if let goalSteps = Int(text), goalSteps > 1000 {
                    self.updateGoal(steps: goalSteps)
                }else{
                    print("Could not update steps")
                }
            }))
            customGoalAlertController.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
            self.present(customGoalAlertController, animated: true, completion: nil)
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func updateGoal(steps:Int){
        if let obj = UserGoal.getAll().first, let goal = obj as? UserGoal{
            let realm = try! Realm()
            try! realm.write {
                goal.goalSteps = steps
            }
            getAppDelegate().setGoal()
            percentageLabel.text = String(format:"Goal: %d",(steps))
            self.setCircleProgress(lastSyncedSteps, goalValue: steps)
        }
    }
    
    func dismissViewController(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        _ = SwiftEventBus.onMainThread(self, name: SWIFTEVENT_BUS_SMALL_SYNCACTIVITY_DATA) { (notification) in
            if self.didSelectedDate.beginningOfDay == Date().beginningOfDay {
                let rawGoalPacket:StepsGoalPacket = notification.object as! StepsGoalPacket
                DTUserDefaults.setLastSmallSync(steps: rawGoalPacket.getDailySteps(), goal: rawGoalPacket.getGoal(), timeinterval: Date().timeIntervalSince1970)
                self.getLoclSmallSyncData()
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
            if unwrappedData is SendStepsToWatchCache {
                let cacheSendSteps:SendStepsToWatchCache = unwrappedData as! SendStepsToWatchCache
                let date:Date = Date(timeIntervalSince1970: cacheSendSteps.date)
                if date == Date().beginningOfDay {
                    AppDelegate.getAppDelegate().setStepsToWatch()
                }
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
        AppDelegate.getAppDelegate().getGoal()
        
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
    
    func getLoclSmallSyncData(){
        let lastSynced = DTUserDefaults.lastSmallSync()
        let smallDate = Date(timeIntervalSince1970: lastSynced.timeInterval)
        let dailySteps:Int = lastSynced.steps
        let stepsGoal:Int = lastSynced.goal
        if smallDate.beginningOfDay == Date().beginningOfDay {
            if let last0X30Data = AppTheme.LoadKeyedArchiverName(IS_SEND_0X30_COMMAND) {
                if last0X30Data is SendStepsToWatchCache {
                    let cacheSendSteps:SendStepsToWatchCache = last0X30Data as! SendStepsToWatchCache
                    let date:Date = Date(timeIntervalSince1970: cacheSendSteps.date)
                    if date.beginningOfDay == Date().beginningOfDay {
                        DispatchQueue.main.async(execute: {
                            // do something
                            let daySteps:Int = cacheSendSteps.steps + dailySteps
                            self.setCircleProgress(daySteps, goalValue: stepsGoal)
                        })
                        
                    }else{
                        self.setCircleProgress(dailySteps , goalValue: stepsGoal)
                    }
                }
            }else{
                self.setCircleProgress(dailySteps, goalValue: stepsGoal)
            }
        }
        
    }
}

extension StepsViewController {
    
    func setCircleProgress(_ stepsValue:Int,goalValue:Int) {
        circleProgressView.setProgress(Double(stepsValue)/Double(goalValue), animated: true)
        stepsButton.setTitle(String(format:"%d",stepsValue), for: .normal)
    }
    
    func bulidChart(_ todayDate:Date) {
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
            let distanceAndCalories = calculationData(activeTime: lastTimeframe,steps: lastSteps)
            self.lastMiles.text = distanceAndCalories.miles
            self.lastCalories.text = distanceAndCalories.calories
            let timer:String = String(format: "%.2f",Double(lastTimeframe)/60)
            let timerArray = timer.components(separatedBy: ".")
            if timerArray[0].toInt() > 0 {
                self.lastActiveTime.text = "\(timerArray[0])h \(String(format: "%.0f",Double("0."+timerArray[1])!*60))m"
            }else{
                self.lastActiveTime.text = "\(lastTimeframe)m"
            }
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
            let dayTime:TimeInterval = Date(year: dayDate.year, month: dayDate.month, day: dayDate.day, hour: 0, minute: 0, second: 0).timeIntervalSince1970
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
            let distanceAndCalories = calculationData(activeTime: thisWeekTime,steps: thisWeekSteps)
            self.thisWeekMiles.text = distanceAndCalories.miles
            self.thisWeekCalories.text = distanceAndCalories.calories
            let timer:String = String(format: "%.2f",Double(thisWeekTime)/60)
            let timerArray = timer.components(separatedBy: ".")
            if timerArray[0].toInt()>0 {
                self.thisWeekActiveTime.text = "\(timerArray[0])h \(String(format: "%.0f",Double("0."+timerArray[1])!*60))m"
            }else{
                self.thisWeekActiveTime.text = "\(timerArray[1])m"
            }
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
            let distanceAndCalories = calculationData(activeTime: lastWeekTime, steps: lastWeekSteps)
            self.lastWeekMiles.text = distanceAndCalories.miles
            self.lastWeekCalories.text = distanceAndCalories.calories
            let timer:String = String(format: "%.2f",Double(lastWeekTime)/60)
            let timerArray = timer.components(separatedBy: ".")
            if timerArray[0].toInt()>0 {
                self.lastWeekActiveTime.text = "\(timerArray[0])h \(String(format: "%.0f",Double("0."+timerArray[1])!*60))m"
            }else{
                self.lastWeekActiveTime.text = "\(timerArray[1])m"
            }
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
            let distanceAndCalories = calculationData(activeTime: lastMonthTime, steps: lastMonthSteps)
            
            self.lastMonthMiles.text = distanceAndCalories.miles
            self.lastMonthCalories.text = distanceAndCalories.calories
            let timer:String = String(format: "%.2f",Double(lastMonthTime)/60)
            let timerArray = timer.components(separatedBy: ".")
            if timerArray[0].toInt() > 0 {
                self.lastMonthActiveTime.text = "\(timerArray[0])h \(String(format: "%.0f",Double("0."+timerArray[1])!*60))m"
            }else{
                self.lastMonthActiveTime.text = "\(timerArray[1])m"
            }
            
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
    
    func calculationData(activeTime:Int,steps:Int) -> (miles:String,calories:String)  {
        var profile = UserProfile()
        if let dbProfile = UserProfile.findAll().first{
            profile = dbProfile
        }
        let strideLength:Double = Double(profile.length)*0.415/100
        let miles:Double = strideLength*Double(steps)/1000
        let calories:Double = (2.0*Double(profile.weight)*3.5)/200 * Double(activeTime)
        return (String(format: "%.2f",miles), String(format: "%.2f",calories))
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
    
    func latestSelectableDate() -> Date {
        return Date()
    }
    
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
        return true
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
        let dayTime:TimeInterval = Date(year: dayDate.year, month: dayDate.month, day: dayDate.day, hour: 0, minute: 0, second: 0).timeIntervalSince1970
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
