//
//  WorldClockController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/25.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit
import MRProgress
import RealmSwift
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


protocol DidSelectedDelegate:NSObjectProtocol {
    func didSelectedLocalTimeZone(_ cityId:Int)
}

class WorldClockViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    fileprivate var time:(hour:Int,minute:Int)
    fileprivate let identifier:String = "WorldClockCell"
    fileprivate var worldClockArray: [City] = []
    fileprivate var localTimeOffsetToGmt: Float
    fileprivate let realm:Realm
    //private var timeZoneOffSet: (hours:Int, minutes:Int)
    
    @IBOutlet weak var worldClockTableview: UITableView!
    
    init() {
        let date = Date()
        realm = try! Realm()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ZZZ"
        var timeZoneString = dateFormatter.string(from: date)
        if timeZoneString.contains("+"){
            timeZoneString = String(timeZoneString.characters.dropFirst())
        }
        let idx0 = timeZoneString.index(timeZoneString.startIndex, offsetBy: 0)
        let idx1 = timeZoneString.index(timeZoneString.startIndex, offsetBy: 2)
        let idx2 = timeZoneString.index(timeZoneString.startIndex, offsetBy: 4)
        
        let hours:String = timeZoneString[idx0..<idx1]
        let minutes:String = timeZoneString[idx1..<idx2]
        let offsetHours = Float(hours)
        let offsetMinutes = Int(minutes)
        localTimeOffsetToGmt = offsetHours!
        if offsetMinutes > 0 {
            localTimeOffsetToGmt += 0.5
        }

        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([ .hour, .minute, .second], from: date)
        time.hour = components.hour!
        time.minute = components.minute!

        super.init(nibName: "WorldClockViewController", bundle: Bundle.main)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "World Clock"
        self.navigationController?.navigationBar.tintColor = UIColor.white

        worldClockTableview.register(UINib(nibName: "WorldClockCell",bundle: Bundle.main), forCellReuseIdentifier: identifier)
        worldClockTableview.backgroundColor = UIColor(rgba: "#E4C590")
        worldClockTableview.allowsSelectionDuringEditing = true;
        worldClockTableview.separatorColor = UIColor.clear
        let header:WorldClockHeader = UIView.loadFromNibNamed("WorldClockHeader") as! WorldClockHeader;
        header.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: header.frame.height)
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        let dateString = "\(formatter.string(from: date))"
        header.dateLabel.text = dateString
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: header.frame.height))
        headerView.addSubview(header)
        worldClockTableview.tableHeaderView = headerView
        self.addPlusButton(#selector(add))
     }
    
    func add(){        
        if worldClockArray.count >= 5 {
            let alert:UIAlertController = UIAlertController(title: "World Clock", message: NSLocalizedString("only_5_world_clock", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        if AppDelegate.getAppDelegate().isConnected() {
            self.present(self.makeStandardUINavigationController(AddWorldClockViewController()), animated: true, completion: nil)
        }else{
            let view = MRProgressOverlayView.showOverlayAdded(to: self.navigationController!.view, title: NSLocalizedString("no_watch_connected", comment: ""), mode: MRProgressOverlayViewMode.cross, animated: true)
            view?.setTintColor(UIColor.getBaseColor())
            Timer.after(0.6.second) {
                view?.dismiss(true)
            }
        }
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        worldClockArray = Array(realm.objects(City.self).filter("selected = true"))
        self.worldClockTableview.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?{
        let button1 = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
            self.tableView(tableView, commit: .delete, forRowAt: indexPath)
        })
        button1.backgroundColor = UIColor.getTintColor()
        return [button1]
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return worldClockArray.count + 1
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (indexPath as NSIndexPath).row == 0 {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let city:City = worldClockArray[(indexPath as NSIndexPath).row - 1]
            try! realm.write({
                city.selected = false
                realm.add(city, update: true)
            })
            
            worldClockArray = Array(realm.objects(City.self).filter("selected = true"))
            tableView.deleteRows(at: [indexPath], with: .fade)
            AppDelegate.getAppDelegate().setWorldClock(worldClockArray)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:WorldClockCell = tableView.dequeueReusableCell(withIdentifier: identifier) as! WorldClockCell
        cell.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: cell.frame.height)
        if (indexPath.row == 0){
            let now = Date()
            
            let timeZoneNameData = DateFormatter().timeZone.identifier.characters.split{$0 == "/"}.map(String.init)
            if timeZoneNameData.count >= 2 {
                cell.cityLabel.text = timeZoneNameData[1].replacingOccurrences(of: "_", with: " ")
            }
            cell.timeDescription.text = "Today"
            var minuteString:String = String(now.minute)
            if (now.minute < 10){
                minuteString = "0\(now.minute)"
            }
            cell.time.text = "\(now.hour):\(minuteString)"
            return cell
        }
        
        let city:City = worldClockArray[((indexPath as NSIndexPath).row - 1)]

        cell.cityLabel.text = city.name
        var foreignTimeOffsetToGmt:Float = 0.0
        if let timezone:Timezone = city.timezone{
            print(timezone.getOffsetFromUTC())
            foreignTimeOffsetToGmt = Float(timezone.getOffsetFromUTC())/60
        }
        
        var text:String = ""
        if foreignTimeOffsetToGmt == localTimeOffsetToGmt  {
            text+="Today"
            cell.time.text = "\(time.hour):\(time.minute < 10 ? "0":"")\(time.minute)"
        }else if foreignTimeOffsetToGmt > localTimeOffsetToGmt{
            let timeAhead = foreignTimeOffsetToGmt - localTimeOffsetToGmt
            let halfAheadHour = timeAhead.truncatingRemainder(dividingBy: 1.0)
            
            var foreignTime:(hour:Int,minute:Int) = (hour:self.time.hour+Int(timeAhead), minute: (halfAheadHour == 0.5 ? self.time.minute + 30 :self.time.minute))
            if foreignTime.minute > 59 {
                foreignTime.minute-=59
                foreignTime.hour+=1
            }
            let hour:String = Int(timeAhead) == 1 ? "hour" : "hours"
            let halfHour :String = timeAhead.truncatingRemainder(dividingBy: 1.0) > 0.0 ? " and 30 minutes " : " "
            if foreignTime.hour > 23 {
                foreignTime.hour-=23
                    text+="Tomorrow, \(Int(timeAhead)) \(hour)\(halfHour)ahead"
            }else{
                    text+="Today, \(Int(timeAhead)) \(hour)\(halfHour)ahead"
            }
            cell.time.text = "\(foreignTime.hour):\(foreignTime.minute < 10 ? "0":"")\(foreignTime.minute)"
        }else if foreignTimeOffsetToGmt < localTimeOffsetToGmt{
            let timeBehind = foreignTimeOffsetToGmt - localTimeOffsetToGmt
            print(timeBehind)
            let halfHourBehind = timeBehind.truncatingRemainder(dividingBy: 1.0)
            var foreignTime:(hour:Int,minute:Int) = (hour:self.time.hour+Int(timeBehind), minute: (abs(halfHourBehind) == 0.5 ? self.time.minute - 30 :self.time.minute))
            if foreignTime.minute < 0 {
                foreignTime.minute+=59
                foreignTime.hour-=1
            }
            let hour:String = Int(timeBehind) == 1 ? "hour" : "hours"
            let halfHour :String = abs(timeBehind).truncatingRemainder(dividingBy: 1.0) > 0.0 ? " and 30 minutes " : " "
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
