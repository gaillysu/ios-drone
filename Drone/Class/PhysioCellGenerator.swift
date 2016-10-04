//
//  PhysioCellGenerator.swift
//  Drone
//
//  Created by Karl-John on 22/9/2016.
//  Copyright © 2016 Cloud. All rights reserved.
//

import Foundation

class PhysioCellGenerator {
    static func getCellFrom(cockroach number:Int, coordinates:CoordinateSet, tableview:UITableView, dequeueIdentifier:String, numberCoordinate:Int = -1) -> UITableViewCell {
        var cell:UITableViewCell
        if let dequeuedCell = tableview.dequeueReusableCell(withIdentifier: dequeueIdentifier){
            cell = dequeuedCell
        }else{
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: dequeueIdentifier)
        }
        cell.textLabel?.text = "Cockroach: \(number)"
        if numberCoordinate == 0 {
            cell.detailTextLabel?.text = "Coordinates: \(coordinates.getString0())"
        } else if numberCoordinate == 1 {
            cell.detailTextLabel?.text = "Coordinates: \(coordinates.getString1())"
        } else if numberCoordinate == 2 {
            cell.detailTextLabel?.text = "Coordinates: \(coordinates.getString2())"
        } else {
            cell.detailTextLabel?.text = "Coordinates: \(coordinates.getString1())"
        }
        
        return cell
    }
}
