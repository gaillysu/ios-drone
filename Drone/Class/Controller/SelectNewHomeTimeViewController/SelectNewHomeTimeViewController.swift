//
//  SelectNewHomeTimeViewController.swift
//  Drone
//
//  Created by Karl-John Chow on 30/6/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class SelectNewHomeTimeViewController: UIViewController {

    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var homeTimeTimeLabel: UILabel!

    let disposeBag = DisposeBag()
    var homeCity = City.homeTime
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter:DateFormatter = DateFormatter()
        formatter.dateFormat = "ZZZ"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home Time"
        self.navigationItem.setHidesBackButton(true, animated: false)
        selectButton.rx.tap.subscribe({ _ in
            let navigationController: UINavigationController = UINavigationController(rootViewController: AddWorldClockViewController(forHomeTime: true))
            navigationController.navigationBar.setBackgroundImage(UIImage(named: "gradually"), for: UIBarMetrics.default)
            let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
            navigationController.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
            self.present(navigationController, animated: true, completion: nil)
        }).addDisposableTo(disposeBag)
        
        nextButton.rx.tap.subscribe({ _ in
            self.navigationController?.pushViewController(CalibrateHourViewController(), animated: true)
        }).addDisposableTo(disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        homeCity = City.homeTime
        if let city = homeCity{
            selectButton.setTitle("\(city.name), \(city.country)", for: .normal)
            calculateTime(model: city)
            nextButton.isHidden = false
        }else{
            nextButton.isHidden = true
        }
    }
    
    func calculateTime(model:City){
        var localTimeOffsetToGmt: Float = 0
        let timeZoneNameData = DateFormatter().localCityName()
        if timeZoneNameData.hasPrefix(model.name)  {
            let now = Date()
            var minuteString:String = String(now.minute)
            if (now.minute < 10){
                minuteString = "0\(now.minute)"
            }
            homeTimeTimeLabel.text = "\(now.hour):\(minuteString)"
        }else{
            let date = Date()
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
            if offsetMinutes! > 0 {
                localTimeOffsetToGmt += 0.5
            }
            let hour = Calendar.current.component(.hour, from: date)
            let minute = Calendar.current.component(.minute, from: date)
            
            var foreignTimeOffsetToGmt:Float = 0.0
            if let timezone:Timezone = model.timezone{
                foreignTimeOffsetToGmt = Float(timezone.getOffsetFromUTC())/60
            }
            if foreignTimeOffsetToGmt == localTimeOffsetToGmt  {
                homeTimeTimeLabel.text = "\(hour):\(minute < 10 ? "0":"")\(minute)"
            }else if foreignTimeOffsetToGmt > localTimeOffsetToGmt{
                let timeAhead = foreignTimeOffsetToGmt - localTimeOffsetToGmt
                let halfAheadHour = timeAhead.truncatingRemainder(dividingBy: 1.0)
                var foreignTime:(hour:Int,minute:Int) = (hour:hour+Int(timeAhead), minute: (halfAheadHour == 0.5 ? minute + 30 : minute))
                if foreignTime.minute > 59 {
                    foreignTime.minute-=59
                    foreignTime.hour+=1
                }
                homeTimeTimeLabel.text = "\(foreignTime.hour):\(foreignTime.minute < 10 ? "0":"")\(foreignTime.minute)"
            }else if foreignTimeOffsetToGmt < localTimeOffsetToGmt{
                let timeBehind = foreignTimeOffsetToGmt - localTimeOffsetToGmt
                let halfHourBehind = timeBehind.truncatingRemainder(dividingBy: 1.0)
                var foreignTime:(hour:Int,minute:Int) = (hour:hour+Int(timeBehind), minute: (abs(halfHourBehind) == 0.5 ? minute - 30 : minute))
                if foreignTime.minute < 0 {
                    foreignTime.minute+=59
                    foreignTime.hour-=1
                }
                homeTimeTimeLabel.text = "\(foreignTime.hour):\(foreignTime.minute < 10 ? "0":"")\(foreignTime.minute)"
            }
        }
    }
}
