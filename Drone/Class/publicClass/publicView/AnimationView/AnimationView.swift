//
//  AnimationView.swift
//  Nevo
//
//  Created by leiyuncun on 15/3/5.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit


protocol ButtonManagerCallBack {

    func controllManager(sender:AnyObject)
    
}

class AnimationView: UIView {

    private var mNoConnectionView:UIView?
    private var mNoConnectImage:UIImageView?
    private var mNoConnectScanButton:UIButton?
    let PICKER_BG_COLOR = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1)//pickerView background color
    let BUTTONBGVIEW_COLOR = UIColor(red: 244/255.0, green: 242/255.0, blue: 241/255.0, alpha: 1)//View button background color
    let NO_CONNECT_VIEW:Int = 1200

    private var mDelegate:ButtonManagerCallBack!

    init(frame: CGRect,delegate:ButtonManagerCallBack) {
        super.init(frame: frame)
        mDelegate = delegate

    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bulibNoConnectView()->UIView{
        if mNoConnectionView==nil {
            mNoConnectionView = UIView(frame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height))
            mNoConnectionView?.backgroundColor = PICKER_BG_COLOR
            mNoConnectionView?.tag = NO_CONNECT_VIEW
            self.addSubview(mNoConnectionView!)

            let message:UILabel = UILabel(frame: CGRectMake(0, 0, 300, 90))
            message.frame = AppTheme.getLabelSize(NSLocalizedString("nevoConnected", comment: ""), andObject: message.frame,andFont: AppTheme.FONT_RALEWAY_LIGHT(mSize: 18));
            message.center = CGPointMake(self.frame.size.width/2, mNoConnectionView!.frame.size.height/2.0-120)
            message.font = AppTheme.FONT_RALEWAY_LIGHT(mSize: 18)
            message.text = NSLocalizedString("nevoConnected", comment: "")
            message.numberOfLines = 0
            message.lineBreakMode = NSLineBreakMode.ByWordWrapping
            message.textAlignment = NSTextAlignment.Center
            message.textColor = UIColor.blackColor()
            mNoConnectionView?.addSubview(message)

            mNoConnectImage = UIImageView(frame: CGRectMake(0, 0, 160, 160))
            mNoConnectImage?.image = UIImage(named: "connect")
            mNoConnectImage?.center = CGPointMake(mNoConnectionView!.frame.size.width/2.0, mNoConnectionView!.frame.size.height/2.0)
            mNoConnectImage?.backgroundColor = UIColor.clearColor()
            mNoConnectionView?.addSubview(mNoConnectImage!)

            mNoConnectScanButton = UIButton(type:UIButtonType.Custom)
            mNoConnectScanButton?.frame = CGRectMake(0, 0, 160, 160)
            mNoConnectScanButton?.center = CGPointMake(mNoConnectionView!.frame.size.width/2.0, mNoConnectionView!.frame.size.height/2.0)

            mNoConnectScanButton?.titleLabel?.font = AppTheme.FONT_RALEWAY_LIGHT(mSize: 18)
            mNoConnectScanButton?.setTitle(NSLocalizedString("Connect", comment: ""), forState: UIControlState.Normal)
            mNoConnectScanButton?.backgroundColor = UIColor.clearColor()
            mNoConnectScanButton?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            mNoConnectScanButton?.addTarget(self, action: Selector("noConnectButtonAction:"), forControlEvents: UIControlEvents.TouchUpInside)
            mNoConnectionView?.addSubview(mNoConnectScanButton!)

            let message2:UILabel = UILabel(frame: CGRectMake(0, 0, 300, 90))
            message2.center = CGPointMake(self.frame.size.width/2, mNoConnectImage!.frame.origin.y+mNoConnectImage!.frame.size.height+55)
            message2.frame = AppTheme.getLabelSize(NSLocalizedString("pushHoldButton", comment: ""), andObject: message2.frame,andFont: AppTheme.FONT_RALEWAY_LIGHT(mSize: 18));
            message2.font = AppTheme.FONT_RALEWAY_LIGHT(mSize: 18)
            message2.text = NSLocalizedString("pushHoldButton", comment: "")
            message2.numberOfLines = 0
            message2.lineBreakMode = NSLineBreakMode.ByWordWrapping
            message2.textAlignment = NSTextAlignment.Center
            message2.textColor = UIColor.blackColor()
            mNoConnectionView?.addSubview(message2)

            let ForgotButton:UIButton = UIButton(type:UIButtonType.Custom)
            ForgotButton.frame = CGRectMake(0, 0, 120, 40)
            ForgotButton.center = CGPointMake(mNoConnectionView!.frame.size.width/2.0, mNoConnectionView!.frame.size.height-120)
            ForgotButton.setBackgroundImage(UIImage(named: "forget_button"), forState: UIControlState.Normal)
            ForgotButton.setTitle(NSLocalizedString("forgetnevo", comment: ""), forState: UIControlState.Normal)
            ForgotButton.titleLabel?.font = AppTheme.FONT_RALEWAY_LIGHT(mSize: 15)
            ForgotButton.backgroundColor = UIColor.clearColor()
            ForgotButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            ForgotButton.addTarget(self, action: Selector("noConnectButtonAction:"), forControlEvents: UIControlEvents.TouchUpInside)
            ForgotButton.tag = 1450
            ForgotButton.layer.masksToBounds = true
            ForgotButton.layer.cornerRadius = 20.0
            //ForgotButton.layer.borderWidth = 2;//边框宽度
            //ForgotButton.layer.borderColor = AppTheme.NEVO_SOLAR_YELLOW().CGColor
            mNoConnectionView!.addSubview(ForgotButton)

            /**
            *  Adapter German text
            */
            if(AppTheme.getPreferredLanguage().isEqualToString("de")){
                message.font = AppTheme.FONT_RALEWAY_LIGHT(mSize: 15)
                message2.font = AppTheme.FONT_RALEWAY_LIGHT(mSize: 15)
            }

            if(AppTheme.GET_IS_iPhone4S()){
                message.frame = CGRectMake(self.frame.size.width/2-150, 90, 300, message.frame.size.height)
                mNoConnectImage?.frame = CGRectMake(mNoConnectionView!.frame.size.width/2.0-60, message.frame.size.height+message.frame.origin.y, 120, 120)
                mNoConnectScanButton?.frame = CGRectMake(mNoConnectionView!.frame.size.width/2.0-60, message.frame.size.height+message.frame.origin.y, 120, 120)
                message2.frame = CGRectMake(self.frame.size.width/2-150, mNoConnectImage!.frame.size.height+mNoConnectImage!.frame.origin.y+10, 300, message.frame.size.height)
            }


        } else {

            if let noConnect:UIView = mNoConnectionView {
                UIView.animateKeyframesWithDuration(0.3, delay: 0, options: UIViewKeyframeAnimationOptions.LayoutSubviews, animations: { () -> Void in

                    noConnect.alpha = 1;

                    }) { (Bool) -> Void in
                        noConnect.hidden=false
                }
            }
        }
        return mNoConnectionView!
    }

    func noConnectButtonAction(sender:UIButton){
        //forgot the address to reconnect
        AppTheme.DLog("noConnectScanButton")
        if (sender.tag == 1450){
            AppTheme.DLog("forgot the watch address before \(NSUserDefaults.standardUserDefaults().objectForKey(ConnectionControllerImpl.Const.SAVED_ADDRESS_KEY))")
            NSUserDefaults.standardUserDefaults().removeObjectForKey(ConnectionControllerImpl.Const.SAVED_ADDRESS_KEY)
            MBProgressHUD.showSuccess(NSLocalizedString("unpairednevo",comment: ""))
        }else{
            //CallBack StepGoalSetingController
            mDelegate?.controllManager(sender as UIButton)
        }
    }
    
    func RotatingAnimationObject(sender:UIImageView) {

        let rotationAnimation:CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(double: M_PI * 2.0);
        rotationAnimation.duration = 1;
        rotationAnimation.cumulative = true;
        rotationAnimation.repeatCount = 10;
        rotationAnimation.delegate = self
        rotationAnimation.fillMode = kCAFillModeForwards;
        rotationAnimation.removedOnCompletion = false
        sender.layer.addAnimation(rotationAnimation, forKey: "NoButtonRotationAnimation")
    }

    func endConnectRemoveView() {

        if let noConnect:UIView = mNoConnectionView {
            UIView.animateKeyframesWithDuration(0.5, delay: 0, options: UIViewKeyframeAnimationOptions.LayoutSubviews, animations: { () -> Void in

                noConnect.alpha = 0;

                }) { (Bool) -> Void in
                    noConnect.hidden=true
            }
        }
    }

    /**
    * Animation Start
    */
    override func animationDidStart(theAnimation:CAAnimation)
    {
        AppTheme.DLog("begin");
        mNoConnectScanButton?.enabled = false
        mNoConnectScanButton?.setTitleColor(AppTheme.NEVO_SOLAR_GRAY(), forState: UIControlState.Normal)
    }

    /**
    * Animation Stop
    */
    override func animationDidStop(theAnimation:CAAnimation ,finished:Bool){
        AppTheme.DLog("end");
        mNoConnectScanButton?.enabled = true
        mNoConnectScanButton?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
    }

    func getNoConnectScanButton() -> UIButton? {
        return mNoConnectScanButton
    }

    func getNoConnectImage() -> UIImageView? {
        return mNoConnectImage
    }

    func getmNoConnectionView()->UIView{
        return mNoConnectionView!
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}

class CircleProgressView: CAShapeLayer {

    private let progressLimit:CGFloat = 1.0 //The overall progress of the progress bar
    private var progress:CGFloat = 0 //The progress bar target schedule
    private var percent:CGFloat {
        //Calculating the percentage of the current value
        return CGFloat(calculatePercent(progress, toProgress: progressLimit))
    }
    private var initialProgress:CGFloat!
    private var progressLayer:CAShapeLayer! //The progress bar object
    private var progressColor:UIColor = UIColor.greenColor() //The background color of the progress bar

    override init(){
        super.init()
        //self.path = drawPathWithArcCenter()
        self.fillColor = UIColor.clearColor().CGColor
        //self.strokeColor = UIColor(red: 0.56, green: 0.56, blue: 0.56, alpha: 0.4).CGColor
        //self.lineWidth = 5

        progressLayer = CAShapeLayer()
        progressLayer.path = drawPathWithArcCenter()
        progressLayer.fillColor = UIColor.clearColor().CGColor
        progressLayer.strokeColor = progressColor.CGColor
        progressLayer.lineWidth = 5

        self.addSublayer(progressLayer)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSublayers() {
        self.path = drawPathWithArcCenter()
        progressLayer.path = drawPathWithArcCenter()
        super.layoutSublayers()
    }

    /*
    Used to calculate the rotate degree
    */
    private func DegreesToRadians(degrees:CGFloat) -> CGFloat {

        return (degrees * CGFloat(M_PI))/180.0;
    }
    
    /**
    The progress path function

    :returns: Returns the drawing need path
    */
    func drawPathWithArcCenter()->CGPathRef{
        let position_y:CGFloat = self.frame.size.height/2.0
        let position_x:CGFloat = self.frame.size.width/2.0
        let path:CGPathRef = UIBezierPath(arcCenter: CGPointMake(position_x, position_y), radius: position_y, startAngle: CGFloat(-M_PI/90), endAngle: CGFloat(4*M_PI/2), clockwise: true).CGPath
        return path
    }

    /**
    Set progress function

    :param: Sprogress You need to set up the current progress
    */
    func setProgress(Sprogress:CGFloat,Steps steps:Int = 0,GoalStep goalstep:Int = 0) {
        initialProgress = CGFloat(calculatePercent(progress, toProgress: progressLimit))

        progress = Sprogress

        self.progressLayer.strokeEnd = self.percent
        startAnimation();
    }

    /**
    Set the background color of the progress bar

    :param: mProgressColor The current progress
    */
    func setProgressColor(mProgressColor:UIColor) {
        progressColor = mProgressColor
        self.progressLayer.strokeColor = progressColor.CGColor;
    }

    private func calculatePercent(fromProgress:CGFloat,toProgress:CGFloat)->Double {
        if ((toProgress > 0) && (fromProgress > 0)) {

            var progress:CGFloat = 0;

            progress = fromProgress / toProgress

            if ((progress * 100) > 100) {
                progress = 1.0;
            }
            return Double(progress);
        }else{

            return 0.0;
        }
    }

    /**
    Implementation of the animation function
    */
    private func startAnimation() {
        let pathAnimation:CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration = 1.0
        pathAnimation.fromValue = initialProgress;
        pathAnimation.toValue = percent;
        pathAnimation.removedOnCompletion = true;
        progressLayer.addAnimation(pathAnimation, forKey: nil)
    }
}

class CircleSleepProgressView: CAShapeLayer {
    private let progressLimit:CGFloat = 1.0 //The overall progress of the progress bar
    private var progress:CGFloat = 1.0 //The progress bar target schedule
    private var percent:CGFloat {
        //Calculating the percentage of the current value
        return CGFloat(calculatePercent(progress, toProgress: progressLimit))
    }
    private var initialProgress:CGFloat!
    private var progressColor:UIColor = UIColor.greenColor() //The background color of the progress bar

    override init(){
        super.init()
        self.path = drawPathWithArcCenter(NSDate(),endtimer:NSDate())
        self.fillColor = UIColor.clearColor().CGColor
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSublayers() {
        super.layoutSublayers()
    }

    /*
    Used to calculate the rotate degree
    */
    private func DegreesToRadians(degrees:Double) -> Double {

        //#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)  (degrees * M_PI)/180.0;
        return (degrees/180.0*M_PI);
    }

    /**
    The progress path function

    :returns: Returns the drawing need path
    */
    func drawPathWithArcCenter(startTimer:NSDate,endtimer:NSDate)->CGPathRef{
        let now:NSDate = startTimer
        let cal:NSCalendar = NSCalendar.currentCalendar()
        let comps:NSDateComponents = cal.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day ,NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second,], fromDate: now);
        comps.timeZone = NSTimeZone.localTimeZone()
        var hour:NSInteger = comps.hour;
        let minute:NSInteger = comps.minute;
        let second:NSInteger = comps.second
        hour = hour > 12 ? hour-12:hour

        let endNow:NSDate = endtimer
        let endcal:NSCalendar = NSCalendar.currentCalendar()
        let endcomps:NSDateComponents = endcal.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day ,NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second,], fromDate: endNow);
        var endhour:NSInteger = endcomps.hour;
        let endminute:NSInteger = endcomps.minute;
        let endsecond:NSInteger = endcomps.second
        endhour = endhour > 12 ? endhour-12:endhour

        var startangle:Double = Double(Double(second)/120.0 + Double(minute)/60.0+Double(hour))*Double(2.0/12.0)-0.5
        var endangle:Double = Double(Double(endsecond)/120.0 + Double(endminute)/60.0+Double(endhour))*Double(2.0/12.0)-0.5

        //AppTheme.DLog("startSecond___\(second,minute,hour)___startangle\(startangle) or endsecond______\(endsecond,endminute,endhour)_____\(endangle)")
        let position_y:CGFloat = self.frame.size.height/2.0
        let position_x:CGFloat = self.frame.size.width/2.0

        if(startangle == endangle){
            return UIBezierPath(arcCenter: CGPointMake(position_x, position_y), radius: position_y, startAngle: 0, endAngle: 0, clockwise: true).CGPath
        }
        if(startangle >= 2){
            startangle = startangle-2
        }

        if(startangle < 0){
            startangle = 1.5+(startangle+0.5)
        }

        if(endangle > 2){
            endangle = endangle-2
        }

        if(endangle < 0){
            endangle = 1.5+(endangle+0.5)
        }
        //AppTheme.DLog("startSecond___\(second,minute,hour)___startangle\(startangle) or endsecond______\(endsecond,endminute,endhour)_____\(endangle)")
        let path:CGPathRef = UIBezierPath(arcCenter: CGPointMake(position_x, position_y), radius: position_y, startAngle: CGFloat(M_PI*startangle), endAngle: CGFloat(M_PI*endangle), clockwise: true).CGPath
        return path
    }

    func setSleepProgress(sleepArray:NSArray){
        let sleepChartArray = combiningSleepData(sleepArray)
        var startDate:NSDate = NSDate()
        var endDate:NSDate = NSDate()

        for(var l:Int = 0; l<(sleepChartArray[0] as! [[NSDate]]).count;l++){
            initialProgress = CGFloat(calculatePercent(1.0, toProgress: progressLimit))

            let pLayer:CAShapeLayer = CAShapeLayer()
            startDate = ((sleepChartArray[0] as! [[NSDate]])[l][0]) //[l][0]
            endDate = ((sleepChartArray[0] as! [[NSDate]])[l][1])
            //AppTheme.DLog("startDate____\(startDate) or endDate______\(endDate)")
            pLayer.path = drawPathWithArcCenter(startDate,endtimer:endDate)
            pLayer.fillColor = UIColor.clearColor().CGColor
            pLayer.strokeColor = (sleepChartArray[1] as! [CGColor])[l]//sleepChartColorArray[l]
            pLayer.lineWidth = 5
            pLayer.strokeEnd = percent
            self.addSublayer(pLayer)
            startSleepAnimation(pLayer);
        }
    }

    /**
    解析睡眠数据

    :param: array 睡眠原始数据

    :returns: 返回解析后的数据
    */
    func combiningSleepData(array:NSArray) -> NSArray {
        let cal:NSCalendar = NSCalendar.currentCalendar()
        var lastTimer:Int = 0
        var startDate:NSDate?
        var endDate:NSDate?
        var sleepChartArray:[[NSDate]] = []
        var sleepChartColorArray:[CGColor] = []
        let todayDate:NSDate = GmtNSDate2LocaleNSDate(NSDate())
        for(var i:Int = 23; i>=12;i--){
            let sleepTimerArray:[Int] = array.objectAtIndex(0).objectAtIndex(0) as! [Int]
            let weakTimerArray:[Int] = array.objectAtIndex(0).objectAtIndex(1) as! [Int]
            let lightTimerArray:[Int] = array.objectAtIndex(0).objectAtIndex(2) as! [Int]
            let deepTimerArray:[Int] = array.objectAtIndex(0).objectAtIndex(3) as! [Int]

            if(sleepTimerArray[i] == 0 && i == 23){
                break
            }

            if(sleepTimerArray[i]==0 && i != 23){
                for(var l:Int = i+1; l<sleepTimerArray.count;l++){
                    lastTimer = 60-sleepTimerArray[l]
                    startDate = cal.dateBySettingHour(l, minute: lastTimer , second:0, ofDate: todayDate, options: NSCalendarOptions())!
                    if(lastTimer+weakTimerArray[l]+lightTimerArray[l] == 60){
                        if(l == 23){
                            endDate = cal.dateBySettingHour(0, minute: 0, second:0, ofDate: todayDate, options: NSCalendarOptions())!
                        }else{
                            endDate = cal.dateBySettingHour(l+1, minute: 0, second:0, ofDate: todayDate, options: NSCalendarOptions())!
                        }

                    }else{
                        endDate = cal.dateBySettingHour(l, minute: lastTimer+weakTimerArray[l]+lightTimerArray[l]  , second:0, ofDate: todayDate, options: NSCalendarOptions())!
                    }
                    sleepChartArray.append([startDate!,endDate!])
                    sleepChartColorArray.append(ChartColorTemplates.getLightSleepColor().CGColor)
                    //AppTheme.DLog("Light startDate____\(startDate) or endDate______\(endDate)")
                    startDate = endDate
                    if(lastTimer+weakTimerArray[l]+lightTimerArray[l]+deepTimerArray[l] == 60){
                        if(l == 23){
                            endDate = cal.dateBySettingHour(0, minute: 0, second:0, ofDate: todayDate, options: NSCalendarOptions())!
                        }else{
                            endDate = cal.dateBySettingHour(l+1, minute: 0, second:0, ofDate: todayDate, options: NSCalendarOptions())!
                        }
                    }else{
                        endDate = cal.dateBySettingHour(l, minute: lastTimer+weakTimerArray[l]+lightTimerArray[l]+deepTimerArray[l]  , second:0, ofDate: todayDate, options: NSCalendarOptions())!
                    }
                    sleepChartArray.append([startDate!,endDate!])
                    sleepChartColorArray.append(ChartColorTemplates.getDeepSleepColor().CGColor)
                    //AppTheme.DLog("Deep startDate____\(startDate) or endDate______\(endDate)")
                }
                break
            }
        }
        if(sleepChartArray.count != 0){
            //计算跨天睡眠(前一天有睡眠数据)
            let sleepTimerArray:[Int] = array.objectAtIndex(1).objectAtIndex(0) as! [Int]
            let weakTimerArray:[Int] = array.objectAtIndex(1).objectAtIndex(1) as! [Int]
            let lightTimerArray:[Int] = array.objectAtIndex(1).objectAtIndex(2) as! [Int]
            let deepTimerArray:[Int] = array.objectAtIndex(1).objectAtIndex(3) as! [Int]

            for(var l:Int = 0; l<sleepTimerArray.count-12;l++){
                if(sleepTimerArray[l] == 0){
                    break
                }
                startDate = endDate
                if(lightTimerArray[l]+weakTimerArray[l] == 60){
                    endDate = cal.dateBySettingHour(l+1, minute: 0, second:0, ofDate: todayDate, options: NSCalendarOptions())!
                }else{
                    endDate = cal.dateBySettingHour(l, minute: lightTimerArray[l]+weakTimerArray[l] , second:0, ofDate: todayDate, options: NSCalendarOptions())!
                }
                sleepChartArray.append([startDate!,endDate!])
                sleepChartColorArray.append(ChartColorTemplates.getLightSleepColor().CGColor)
                //AppTheme.DLog("Light startDate____\(startDate) or endDate______\(endDate)")

                startDate = endDate
                if(lightTimerArray[l]+weakTimerArray[l]+deepTimerArray[l] == 60){
                    endDate = cal.dateBySettingHour(l+1, minute: 0, second:0, ofDate: todayDate, options: NSCalendarOptions())!
                }else{
                    endDate = cal.dateBySettingHour(l, minute: lightTimerArray[l]+weakTimerArray[l]+deepTimerArray[l] , second:0, ofDate: todayDate, options: NSCalendarOptions())!
                }
                sleepChartArray.append([startDate!,endDate!])
                sleepChartColorArray.append(ChartColorTemplates.getDeepSleepColor().CGColor)
                //AppTheme.DLog("Deep startDate____\(startDate) or endDate______\(endDate)")
            }
        }else{
            //跨天后的睡眠计算(前一天无睡眠数据)
            let sleepTimerArray:[Int] = array.objectAtIndex(1).objectAtIndex(0) as! [Int]
            let weakTimerArray:[Int] = array.objectAtIndex(1).objectAtIndex(1) as! [Int]
            let lightTimerArray:[Int] = array.objectAtIndex(1).objectAtIndex(2) as! [Int]
            let deepTimerArray:[Int] = array.objectAtIndex(1).objectAtIndex(3) as! [Int]

            for(var l:Int = 0; l<sleepTimerArray.count-12;l++){
                if(sleepTimerArray[l] == 0){
                    continue
                }
                lastTimer = 60-sleepTimerArray[l]
                if(sleepChartArray.count==0){
                    startDate = cal.dateBySettingHour(l, minute: lastTimer , second:0, ofDate: todayDate, options: NSCalendarOptions())!
                }else{
                    startDate = cal.dateBySettingHour(l, minute: 0 , second:0, ofDate: todayDate, options: NSCalendarOptions())!
                }
                if(lastTimer+lightTimerArray[l]+weakTimerArray[l] == 60){
                    if(sleepChartArray.count == 0 || lightTimerArray[l]+weakTimerArray[l] == 60){
                        endDate = cal.dateBySettingHour(l+1, minute: 0, second:0, ofDate: todayDate, options: NSCalendarOptions())!
                    }else{
                        endDate = cal.dateBySettingHour(l, minute: lightTimerArray[l]+weakTimerArray[l] , second:0, ofDate: todayDate, options: NSCalendarOptions())!
                    }

                }else{
                    endDate = cal.dateBySettingHour(l, minute: lightTimerArray[l]+weakTimerArray[l] , second:0, ofDate: todayDate, options: NSCalendarOptions())!
                }
                sleepChartArray.append([startDate!,endDate!])
                sleepChartColorArray.append(ChartColorTemplates.getLightSleepColor().CGColor)

                startDate = endDate
                if(lightTimerArray[l]+weakTimerArray[l]+deepTimerArray[l] == 60){
                    endDate = cal.dateBySettingHour(l+1, minute: 0, second:0, ofDate: todayDate, options: NSCalendarOptions())!
                }else{
                    if(sleepChartArray.count==1){
                        endDate = cal.dateBySettingHour(l+1, minute: 0, second:0, ofDate: todayDate, options: NSCalendarOptions())!
                    }else{
                        endDate = cal.dateBySettingHour(l, minute: lightTimerArray[l]+weakTimerArray[l]+deepTimerArray[l] , second:0, ofDate: todayDate, options: NSCalendarOptions())!
                    }
                }
                sleepChartArray.append([startDate!,endDate!])
                sleepChartColorArray.append(ChartColorTemplates.getDeepSleepColor().CGColor)
            }
        }

        return NSArray(array: [sleepChartArray,sleepChartColorArray]);
    }

    private func calculatePercent(fromProgress:CGFloat,toProgress:CGFloat)->Double {
        if ((toProgress > 0) && (fromProgress > 0)) {

            var progress:CGFloat = 0;

            progress = fromProgress / toProgress

            if ((progress * 100) > 100) {
                progress = 1.0;
            }
            return Double(progress);
        }else{

            return 0.0;
        }
    }

    /**
    Implementation of the animation function
    */
    private func startSleepAnimation(layer:CAShapeLayer) {
        let pathAnimation:CABasicAnimation = CABasicAnimation(keyPath: "strokeSleepEnd.scale")
        pathAnimation.duration = 1
        pathAnimation.fromValue = initialProgress;
        pathAnimation.toValue = percent;
        pathAnimation.removedOnCompletion = true;
        layer.addAnimation(pathAnimation, forKey: nil)
    }
}