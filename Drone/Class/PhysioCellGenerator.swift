//
//  PhysioCellGenerator.swift
//  Drone
//
//  Created by Karl-John on 22/9/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation

class PhysioCellGenerator {
    static func getCellFrom(cockroach number:Int, coordinates:CoordinateSet, tableview:UITableView, dequeueIdentifier:String) -> UITableViewCell {
        var cell:UITableViewCell
        if let dequeuedCell = tableview.dequeueReusableCell(withIdentifier: dequeueIdentifier){
            cell = dequeuedCell
        }else{
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: dequeueIdentifier)
        }
        cell.textLabel?.text = "Cockroach: \(number)"
        cell.detailTextLabel?.text = "Coordinates: \(coordinates.getString1())"
        return cell
    }
}
