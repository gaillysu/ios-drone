//
//  PresetView.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/3.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class GoalView: UITableView {


    var leftButton:UIBarButtonItem?

    func bulidPresetView(_ navigation:UINavigationItem){
        navigation.title = NSLocalizedString("Preset", comment: "")
        leftButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: Selector("controllManager:"))
        navigation.rightBarButtonItem = leftButton
    }

    func getPresetTableViewCell(_ indexPath:IndexPath,tableView:UITableView,goalArray:[UserGoal])->UITableViewCell{
        let endCellID:String = "PresetTableViewCell"
        var endCell = tableView.dequeueReusableCell(withIdentifier: endCellID)
        if (endCell == nil) {
            let nibs:NSArray = Bundle.main.loadNibNamed("PresetTableViewCell", owner: self, options: nil)
            endCell = nibs.object(at: 0) as? GoalTableViewCell;
            (endCell as! GoalTableViewCell).goalStates.tintColor = UIColor.getBaseColor()
            (endCell as! GoalTableViewCell).goalStates.onTintColor = UIColor.getBaseColor()
        }
        (endCell as! GoalTableViewCell).goalStates.tag = (indexPath as NSIndexPath).row
        
        let goalModel:UserGoal = goalArray[(indexPath as NSIndexPath).row]
        (endCell as! GoalTableViewCell).goalSteps.text = "\(goalModel.goalSteps)"
        (endCell as! GoalTableViewCell).goalName.text = goalModel.label
        (endCell as! GoalTableViewCell).goalStates.isOn = goalModel.status
        if(!goalModel.status){
            (endCell as! GoalTableViewCell).backgroundColor = UIColor.clear
        }
        endCell?.selectionStyle = UITableViewCellSelectionStyle.none;
        return endCell!
    }
 
}
