//
//  WorldClockController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/25.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

protocol didSelectedDelegate:NSObjectProtocol {
    func didSelectedLocalTimeZone(ietm:NSDictionary)
}

class WorldClockViewController: BaseViewController {

    private var time:(hour:Int,minute:Int)
    private let identifier:String = "WorldClockCell"
    private var worldClockArray:NSArray!
    private var timeZoneOffSet: (hours:Int, minutes:Int)
    
    @IBOutlet weak var worldClockTableview: UITableView!
    
    init() {
        self.worldClockArray = WorldClockModel.getAll();
        let date = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "ZZZ"
        var timeZoneString = dateFormatter.stringFromDate(date)
        if timeZoneString.containsString("+"){
            timeZoneString = String(timeZoneString.characters.dropFirst())
            let hours:String = timeZoneString[0...1]
            let minutes:String = timeZoneString[2...3]
            let offsetHours = Int(hours)
            let offsetMinutes = Int(minutes)
            timeZoneOffSet.hours = offsetHours!
            timeZoneOffSet.minutes = offsetMinutes!
        }else{
            let hours = timeZoneString[0...2]
            let minutes = timeZoneString[3...4]
            let offsetHours = Int(hours)
            let offsetMinutes = Int(minutes)
            timeZoneOffSet.hours = offsetHours!
            timeZoneOffSet.minutes = offsetMinutes!
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
        self.presentViewController(self.makeStandardUINavigationController(AddWorldClockViewController()), animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.worldClockArray = WorldClockModel.getAll();
        self.worldClockTableview.reloadData()
    }
    
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (worldClockArray.count + 1)
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
        } else if editingStyle == .Insert {
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:WorldClockCell = tableView.dequeueReusableCellWithIdentifier(identifier) as! WorldClockCell
        if(indexPath.row == 0){
            let timeZone: String = NSTimeZone.localTimeZone().name
            let timeZoneArray:[String] = timeZone.characters.split{$0 == "/"}.map(String.init)
            cell.cityLabel.text = timeZoneArray[1].stringByReplacingOccurrencesOfString("_", withString: " ")
            cell.timeDescription.text = "Today"
            cell.time.text = "\(time.hour):\(time.minute)"
            return cell;
        }
        let clock:WorldClockModel = worldClockArray[(indexPath.row - 1)] as! WorldClockModel
        cell.cityLabel.text = clock.city_name
        
        let gmtClock = clock.gmt_offset[1...clock.gmt_offset.characters.count-1]
        let clockOffset = Int(gmtClock)
        
        var text:String = ""
        
        let difference = timeZoneOffSet.hours - clockOffset!
        if difference > 0  {
            let hour = difference-clockOffset!;
            if hour <= 0{
                text+="Yesterday, "
            }else{
                text+="Today, "
            }
            if difference == 1{
                if timeZoneOffSet.minutes > 0 {
                    text+="1 hour and 30 minutes behind"
                }else{
                    text+="1 hour behind"
                }
            }else{
                if timeZoneOffSet.minutes > 0 {
                    text+="\(difference) hours and 30 minutes behind"
                }else{
                    text+="\(difference) hours behind"
                }
            }
            time.hour-difference
        }else if difference < 0{
            let hour = difference+clockOffset!
            if hour >= 24 {
                text+="Tomorrow, "
            }else{
                text+="Today, "
            }
            if difference == -1{
                if timeZoneOffSet.minutes > 0 {
                    text+="1 hour and 30 minutes ahead"
                }else{
                    text+="1 hour ahead"
                }
            }else{
                if timeZoneOffSet.minutes > 0 {
                    text+="\(difference) hours and 30 minutes ahead"
                }else{
                    text+="\(difference) hours ahead"
                }
            }
        } else if timeZoneOffSet.minutes > 0{
            text+=" 30 minutes ahead"
        }else {
            text+=" Today"
        }
        cell.timeDescription.text = text
        return cell;
    }
}
