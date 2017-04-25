//
//  WorldClockCell.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/25.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class WorldClockCell: UITableViewCell {
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter:DateFormatter = DateFormatter()
        formatter.dateFormat = "ZZZ"
        return formatter
    }()
    
    fileprivate var localTimeOffsetToGmt: Float = 0
    fileprivate var timeInfo:(hour:Int,minute:Int) = (0,0)
    var cityModel:City? {
        didSet{
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
            timeInfo.hour = Calendar.current.component(.hour, from: date)
            timeInfo.minute = Calendar.current.component(.minute, from: date)
            
            cityLabel.text = cityModel?.name
            var foreignTimeOffsetToGmt:Float = 0.0
            if let timezone:Timezone = cityModel?.timezone{
                foreignTimeOffsetToGmt = Float(timezone.getOffsetFromUTC())/60
            }
            
            var text:String = ""
            if foreignTimeOffsetToGmt == localTimeOffsetToGmt  {
                text+="Today"
                time.text = "\(timeInfo.hour):\(timeInfo.minute < 10 ? "0":"")\(timeInfo.minute)"
            }else if foreignTimeOffsetToGmt > localTimeOffsetToGmt{
                let timeAhead = foreignTimeOffsetToGmt - localTimeOffsetToGmt
                let halfAheadHour = timeAhead.truncatingRemainder(dividingBy: 1.0)
                
                var foreignTime:(hour:Int,minute:Int) = (hour:self.timeInfo.hour+Int(timeAhead), minute: (halfAheadHour == 0.5 ? timeInfo.minute + 30 : timeInfo.minute))
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
                time.text = "\(foreignTime.hour):\(foreignTime.minute < 10 ? "0":"")\(foreignTime.minute)"
            }else if foreignTimeOffsetToGmt < localTimeOffsetToGmt{
                let timeBehind = foreignTimeOffsetToGmt - localTimeOffsetToGmt
                let halfHourBehind = timeBehind.truncatingRemainder(dividingBy: 1.0)
                var foreignTime:(hour:Int,minute:Int) = (hour:timeInfo.hour+Int(timeBehind), minute: (abs(halfHourBehind) == 0.5 ? timeInfo.minute - 30 : timeInfo.minute))
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
                time.text = "\(foreignTime.hour):\(foreignTime.minute < 10 ? "0":"")\(foreignTime.minute)"
            }
            timeDescription.text = text
        }
    }
    
    @IBOutlet weak var time: UILabel!

    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var timeDescription: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
