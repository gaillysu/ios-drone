//
//  DroneTabbar.swift
//  Drone
//
//  Created by leiyuncun on 16/4/19.
//  Copyright © 2016年 Cloud. All rights reserved.
//

import UIKit
import UIColor_Hex_Swift

protocol SelectedItemDelegate:NSObjectProtocol {
    func didSelectedTabbarItem(item: Int)
}

class DroneTabbar: UIView {

    var delegate:SelectedItemDelegate?

    init() {
        super.init(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 49.0))
        self.backgroundColor = UIColor(patternImage: UIImage(named: "gradually")!)
        self.bulidDroneTabbar()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bulidDroneTabbar() {
        for i:Int in 0  ..< 5 {
            let btn:DroneTabbarItem = DroneTabbarItem()
            btn.adjustsImageWhenHighlighted=false
            btn.adjustsImageWhenDisabled=false
            let btnW:CGFloat = self.frame.size.width/5.0;
            let btnX:CGFloat = CGFloat(i) * btnW;
            let btnY:CGFloat = 0;
            let btnH:CGFloat = self.frame.size.height;

            btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
            var imageName:String = "tabbar\(i)"
            var selImageName:String = "tabbar_selected\(i)"
            var title:String = ""
            if (i==0) {
                title = "Word Clock";
            }else if(i==1){
                title = "Analysis";
            }else if(i==2){
                imageName = "tabbar2";
                selImageName = "tabbar_selected2";
            }else if(i==3){
                title = "Watch Seting";
            }else if(i==4){
                title = "Profile";
            }

            btn.setImage(UIImage(named: imageName), forState: UIControlState.Normal)
            btn.setImage(UIImage(named: selImageName), forState: UIControlState.Selected)

            btn.tag = i;
            if (i != 2) {
                btn.titleLabel?.font = UIFont.boldSystemFontOfSize(8)
                btn.setTitle(title, forState: UIControlState.Normal)

                let imageSize = btn.imageRectForContentRect(btn.frame)
                let titleFont = btn.titleLabel?.font!
                let titleSize = title.sizeWithAttributes([NSFontAttributeName: titleFont!])

                btn.titleEdgeInsets = UIEdgeInsets(top: (imageSize.height + titleSize.height),left: -(imageSize.width), bottom: 20, right: 0)
                btn.imageEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 15, right: 10)

                btn.titleLabel!.textAlignment = NSTextAlignment.Center
                btn.setTitleColor(UIColor.init(colorLiteralRed: 29/255.0, green: 173/255.0, blue: 248/255.0, alpha: 1.0), forState: UIControlState.Selected)
                btn.setTitleColor(UIColor.init(colorLiteralRed: 128/255.0, green: 128/255.0, blue: 128/255.0, alpha: 1.0), forState: UIControlState.Selected)
                self.addSubview(btn)
                btn.addTarget(self, action: #selector(DroneTabbar.btnClick(_:)), forControlEvents: UIControlEvents.TouchDown)
            }
            btn.imageView!.contentMode = UIViewContentMode.ScaleAspectFit;

            if(i == 0){
                self.btnClick(btn)
            }
        }
    }

    func btnClick(sender:UIButton) {
        delegate?.didSelectedTabbarItem(sender.tag)
    }

}
