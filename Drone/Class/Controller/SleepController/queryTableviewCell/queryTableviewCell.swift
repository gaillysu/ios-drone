//
//  queryTableviewCell.swift
//  Nevo
//
//  Created by leiyuncun on 15/8/17.
//  Copyright (c) 2015年 Nevo. All rights reserved.
//

import UIKit

class queryTableviewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!

    var titleString:String?
    var detailString:String?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.textColor = UIColor.white
        titleLabel.font = AppTheme.FONT_RALEWAY_LIGHT(mSize: 15)
        detailLabel.textColor = UIColor.white
        detailLabel.font = AppTheme.FONT_RALEWAY_BOLD(mSize: 16)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let sFrame:CGRect = AppTheme.getWidthLabelSize(titleString!, andObject: titleLabel.frame, andFont: AppTheme.FONT_RALEWAY_LIGHT(mSize: 15))
        titleLabel.frame = CGRect(x: titleLabel.frame.origin.x, y: titleLabel.frame.origin.y, width: sFrame.size.width, height: titleLabel.frame.size.height)

        let detailFrame:CGRect = AppTheme.getWidthLabelSize(detailString!, andObject: detailLabel.frame, andFont: AppTheme.FONT_RALEWAY_BOLD(mSize: 16))
        detailLabel.frame = CGRect(x: titleLabel.frame.origin.x+titleLabel.frame.size.width+5, y: detailLabel.frame.origin.y, width: detailFrame.size.width, height: detailLabel.frame.size.height)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
