//
//  CompassTableViewCell.swift
//  Drone
//
//  Created by Karl-John Chow on 18/4/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import UIKit
import Font_Awesome_Swift
class CompassTableViewCell: UITableViewCell {

    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var valueTextField: UITextField!
    @IBOutlet weak var seperatorview: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        arrowImageView.setFAIconWithName(icon: .FAChevronRight, textColor: UIColor.white)
    }
}
