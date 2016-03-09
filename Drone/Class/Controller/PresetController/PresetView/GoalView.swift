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

    func bulidPresetView(navigation:UINavigationItem){
        navigation.title = NSLocalizedString("Preset", comment: "")
        leftButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: Selector("controllManager:"))
        navigation.rightBarButtonItem = leftButton
    }

    func getPresetTableViewCell(indexPath:NSIndexPath,tableView:UITableView,goalArray:[UserGoal])->UITableViewCell{
        let endCellID:String = "PresetTableViewCell"
        var endCell = tableView.dequeueReusableCellWithIdentifier(endCellID)
        if (endCell == nil) {
            let nibs:NSArray = NSBundle.mainBundle().loadNibNamed("PresetTableViewCell", owner: self, options: nil)
            endCell = nibs.objectAtIndex(0) as? GoalTableViewCell;
            (endCell as! GoalTableViewCell).goalStates.tintColor = AppTheme.NEVO_SOLAR_YELLOW()
            (endCell as! GoalTableViewCell).goalStates.onTintColor = AppTheme.NEVO_SOLAR_YELLOW()
        }
        (endCell as! GoalTableViewCell).goalStates.tag = indexPath.row
        
        let goalModel:UserGoal = goalArray[indexPath.row]
        (endCell as! GoalTableViewCell).goalSteps.text = "\(goalModel.goalSteps)"
        (endCell as! GoalTableViewCell).goalName.text = goalModel.label
        (endCell as! GoalTableViewCell).goalStates.on = goalModel.status
        if(!goalModel.status){
            (endCell as! GoalTableViewCell).backgroundColor = UIColor.clearColor()
        }
        endCell?.selectionStyle = UITableViewCellSelectionStyle.None;
        return endCell!
    }
 
}
