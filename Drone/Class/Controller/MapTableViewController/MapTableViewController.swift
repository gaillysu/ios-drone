//
//  MapTableViewController.swift
//  Drone
//
//  Created by Cloud on 2017/5/5.
//  Copyright © 2017年 Cloud. All rights reserved.
//

import UIKit
import SnapKit
import SwiftEventBus

class MapTableViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
        
    @IBOutlet weak var addresTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var gripperView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addresTableView.register(UINib(nibName: "MapViewCell", bundle: nil), forCellReuseIdentifier: "MapViewCell_Identifier")
        
        searchBar.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MapViewCell_Identifier", for: indexPath)


        return cell
    }
}

extension MapTableViewController:UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        NSLog("searchText:%@",searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        NSLog("searchBar.text:%@",searchBar.text!)
        
        SwiftEventBus.post(SEARCH_ACTION_CLICK, sender: searchBar.text)
    }
}
