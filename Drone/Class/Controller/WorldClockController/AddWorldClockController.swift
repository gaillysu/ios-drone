//
//  AddWorldClockController.swift
//  Nevo
//
//  Created by leiyuncun on 15/12/25.
//  Copyright © 2015年 Nevo. All rights reserved.
//

import UIKit

class AddWorldClockController: UIViewController {

    @IBOutlet weak var addClockView: AddWorldClockView!
    var mDelegate:didSelectedDelegate?

    let clockArray:[NSDictionary] = AppTheme.loadResourcesFile("localTimeZone")

    init() {
        super.init(nibName: "AddWorldClockController", bundle: NSBundle.mainBundle())

    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let array = clockArray
        NSLog("添加时区解析")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        mDelegate?.didSelectedLocalTimeZone(clockArray[indexPath.row])
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clockArray.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("AddClockIdentifier")
        if(cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "AddClockIdentifier")
        }
        let cellDict:NSDictionary = clockArray[indexPath.row] 
        cellDict.enumerateKeysAndObjectsUsingBlock({ (key, obj, stop) -> Void in
            cell?.textLabel?.text = key as? String
             cell?.detailTextLabel?.text = obj as? String
        })

       return cell!
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
