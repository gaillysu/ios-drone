//
//  WorldClockHeader.swift
//  Drone
//
//  Created by Karl-John on 25/4/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation
import UIKit
class WorldClockHeader: UIView{

    var actionHandler:((_ result:AnyObject?) -> Void)?

    @IBOutlet weak var mapImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    class func getWorldClockHeader()->WorldClockHeader {
        if let nibView = UIView.loadFromNibNamed("WorldClockHeader") {
            let worldView:WorldClockHeader = nibView as! WorldClockHeader
            let imagePath:String = Bundle.main.path(forResource: "mapImage", ofType: "png")!
            if let imageValue = UIImage(contentsOfFile: imagePath) {
                worldView.mapImage.image = imageValue
            }
            return worldView
        }
        return WorldClockHeader()
    }
}
