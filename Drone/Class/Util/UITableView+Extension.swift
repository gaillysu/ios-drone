//
//  UITableViewExtension.swift
//  Drone
//
//  Created by Karl-John Chow on 21/4/2017.
//  Copyright © 2017 Cloud. All rights reserved.
//

import UIKit
import struct Foundation.IndexPath
import RxSwift
import RxCocoa


protocol ReusableView: class {
    static var reuseIdentifier: String {get}
}

extension ReusableView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: ReusableView {
}

extension UITableView {
    
    func dequeueReusableCell<T: UITableViewCell>(forIndexPath indexPath: IndexPath) -> T where T: ReusableView {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        return cell
    }
    
    func cellForRowAt<T: UITableViewCell>(forIndexPath indexPath: IndexPath) -> T where T: ReusableView {
        guard let cell = cellForRow(at: indexPath) as? T else {
            fatalError("Could not get cell cell for indexPath: \(indexPath))")
        }
        return cell
    }
}

extension Reactive where Base: UITableView {
    
    var didHighlightRowAt: ControlEvent<IndexPath> {
        let selector = #selector(UITableViewDelegate.tableView(_:didHighlightRowAt:))
        let events = delegate
            .methodInvoked(selector)
            .filter({ ($0.last as? IndexPath) != nil })
            .map({ $0.last as! IndexPath })
        return ControlEvent(events: events)
    }
}
