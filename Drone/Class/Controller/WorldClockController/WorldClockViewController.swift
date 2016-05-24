//
//  WorldClockController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/25.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit
import MRProgress

protocol didSelectedDelegate:NSObjectProtocol {
    func didSelectedLocalTimeZone(ietm:NSDictionary)
}

class WorldClockViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    private var time:(hour:Int,minute:Int)
    private let identifier:String = "WorldClockCell"
    private var worldClockArray:NSArray = NSArray()
    private var localTimeOffsetToGmt: Float
    //private var timeZoneOffSet: (hours:Int, minutes:Int)
    
    @IBOutlet weak var worldClockTableview: UITableView!
    
    init() {
        let date = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "ZZZ"
        var timeZoneString = dateFormatter.stringFromDate(date)
        if timeZoneString.containsString("+"){
            timeZoneString = String(timeZoneString.characters.dropFirst())
            let hours:String = timeZoneString[0...1]
            let minutes:String = timeZoneString[2...3]
            let offsetHours = Float(hours)
            let offsetMinutes = Int(minutes)
            localTimeOffsetToGmt = offsetHours!
            if offsetMinutes > 0 {
                    localTimeOffsetToGmt += 0.5
            }
        }else{
            let hours = timeZoneString[0...2]
            let minutes = timeZoneString[3...4]
            let offsetHours = Float(hours)
            let offsetMinutes = Int(minutes)
            localTimeOffsetToGmt = offsetHours!
            if offsetMinutes > 0 {
                localTimeOffsetToGmt += 0.5
            }
        }
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([ .Hour, .Minute, .Second], fromDate: date)
        time.hour = components.hour
        time.minute = components.minute

        super.init(nibName: "WorldClockViewController", bundle: NSBundle.mainBundle())
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "World Clock"
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()

        worldClockTableview.registerNib(UINib(nibName: "WorldClockCell",bundle: NSBundle.mainBundle()), forCellReuseIdentifier: identifier)
        worldClockTableview.backgroundColor = UIColor(rgba: "#E4C590")
        worldClockTableview.allowsSelectionDuringEditing = true;
        worldClockTableview.separatorColor = UIColor.clearColor()
        let header:WorldClockHeader = UIView.loadFromNibNamed("WorldClockHeader") as! WorldClockHeader;
        header.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, header.frame.height)
        let headerView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, header.frame.height))
        headerView.addSubview(header)
        worldClockTableview.tableHeaderView = headerView
        let button: UIButton = UIButton(type: UIButtonType.Custom)
        button.setImage(UIImage(named: "addbutton"), forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(add), forControlEvents: UIControlEvents.TouchUpInside)
        button.frame = CGRectMake(0, 0, 30, 30)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
     }
    
    func add(){
//        if AppDelegate.getAppDelegate().isConnected() {
            self.presentViewController(self.makeStandardUINavigationController(AddWorldClockViewController()), animated: true, completion: nil)
//        }else{
//            let view = MRProgressOverlayView.showOverlayAddedTo(self.navigationController!.view, title: NSLocalizedString("no_watch_connected", comment: ""), mode: MRProgressOverlayViewMode.Cross, animated: true)
//            view.setTintColor(UIColor.getBaseColor())
//            NSTimer.after(0.6.second) {
//                view.dismiss(true)
//            }
//        }
    }
    

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.worldClockArray = WorldClock.getAll();
        self.worldClockTableview.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?{
        let button1 = UITableViewRowAction(style: .Default, title: "Delete", handler: { (action, indexPath) in
            self.tableView(tableView, commitEditingStyle: .Delete, forRowAtIndexPath: indexPath)
        })
        button1.backgroundColor = UIColor.getTintColor()
        return [button1]
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (worldClockArray.count + 1)
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        }
        return true
    }
    

    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let clock:WorldClock = worldClockArray.objectAtIndex(indexPath.row-1) as! WorldClock
            clock.remove()
            self.worldClockArray = WorldClock.getAll();
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)

            var clockNameArray:[String] = []
            var zoneArray:[Int] = []
            for (index,value) in worldClockArray.enumerate() {
                let worldclock:WorldClock = value as! WorldClock
                let beforeGmt:Int = Int(TimeUtil.getGmtOffSetForCity(worldclock.system_name))
                clockNameArray.append(worldclock.city_name)
                zoneArray.append(beforeGmt)
            }
            AppDelegate.getAppDelegate().setWorldClock(SetWorldClockRequest(count: zoneArray.count, timeZone: zoneArray, name: clockNameArray))
        } else if editingStyle == .Insert {

        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:WorldClockCell = tableView.dequeueReusableCellWithIdentifier(identifier) as! WorldClockCell
        cell.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, cell.frame.height)
        if(indexPath.row == 0){
            let timeZone: String = NSTimeZone.localTimeZone().name
            let timeZoneArray:[String] = timeZone.characters.split{$0 == "/"}.map(String.init)
            cell.cityLabel.text = timeZoneArray[1].stringByReplacingOccurrencesOfString("_", withString: " ")
            cell.timeDescription.text = "Today"
            cell.time.text = "\(time.hour):\(time.minute < 10 ? "0":"")\(time.minute)"
            return cell;
        }

        let worldClockCity:WorldClock = worldClockArray[(indexPath.row - 1)] as! WorldClock
        cell.cityLabel.text = worldClockCity.city_name
        
        let foreignTimeOffsetToGmt = Float(TimeUtil.getGmtOffSetForCity(worldClockCity.system_name))
        var text:String = ""
        if foreignTimeOffsetToGmt == localTimeOffsetToGmt  {
            text+="Today"
            cell.time.text = "\(time.hour):\(time.minute < 10 ? "0":"")\(time.minute)"
        }else if foreignTimeOffsetToGmt > localTimeOffsetToGmt{
            let timeAhead = foreignTimeOffsetToGmt - localTimeOffsetToGmt
            let halfAheadHour = timeAhead % 1.0
            
            var foreignTime:(hour:Int,minute:Int) = (hour:self.time.hour+Int(timeAhead), minute: (halfAheadHour == 0.5 ? self.time.minute + 30 :self.time.minute))
            if foreignTime.minute > 59 {
                foreignTime.minute-=59
                foreignTime.hour+=1
            }
            let hour:String = Int(timeAhead) == 1 ? "hour" : "hours"
            let halfHour :String = timeAhead % 1.0 > 0.0 ? " and 30 minutes " : " "
            if foreignTime.hour > 23 {
                foreignTime.hour-=23
                    text+="Tomorrow, \(Int(timeAhead)) \(hour)\(halfHour)ahead"
            }else{
                    text+="Today, \(Int(timeAhead)) \(hour)\(halfHour)ahead"
            }
            cell.time.text = "\(foreignTime.hour):\(foreignTime.minute < 10 ? "0":"")\(foreignTime.minute)"
        }else if foreignTimeOffsetToGmt < localTimeOffsetToGmt{
            let timeBehind = foreignTimeOffsetToGmt - localTimeOffsetToGmt
            let halfHourBehind = timeBehind % 1.0
            var foreignTime:(hour:Int,minute:Int) = (hour:self.time.hour+Int(timeBehind), minute: (abs(halfHourBehind) == 0.5 ? self.time.minute - 30 :self.time.minute))
            if foreignTime.minute < 0 {
                foreignTime.minute+=59
                foreignTime.hour-=1
            }
            let hour:String = Int(timeBehind) == 1 ? "hour" : "hours"
            let halfHour :String = abs(timeBehind) % 1.0 > 0.0 ? " and 30 minutes " : " "
            if foreignTime.hour < 0 {
                foreignTime.hour+=24
                text+="Yesterday, \(Int(timeBehind)) \(hour)\(halfHour)behind"
            }else{
                text+="Today, \(Int(timeBehind)) \(hour)\(halfHour)behind"
            }
            cell.time.text = "\(foreignTime.hour):\(foreignTime.minute < 10 ? "0":"")\(foreignTime.minute)"
        }
        cell.timeDescription.text = text
        return cell;
    }
}
