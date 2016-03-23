//
//  WelcomeViewController.swift
//  CMO
//
//  Created by Charl on 2/4/16.
//  Copyright © 2016 Octans Corp. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class CLVisitsTableViewController: UITableViewController {
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let settings = Settings()
    var savedVisits = [NSDictionary]()
    let fileManager = NSFileManager.defaultManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 70 // the height of the cell
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let resultDictionary = NSMutableDictionary(contentsOfFile: visitsDataPath)
        savedVisits = resultDictionary?.objectForKey("visits") as! [NSDictionary]
        tableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        //tableDataAvailability(self.clVisitList)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func uploadToServer(sender: AnyObject) {
        
    }
    
    
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.navigationItem.title = "Visits - (\(savedVisits.count))"
        
        if savedVisits.count == 0{
            let emptyLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
            
            emptyLabel.text = "No Data to Display!"
            emptyLabel.textColor = UIColor.grayColor()
            emptyLabel.textAlignment = .Center
            
            self.tableView.backgroundView = emptyLabel
            self.tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            return 0
        } else {
            return savedVisits.count
        }
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:VMTableViewCell = tableView.dequeueReusableCellWithIdentifier("visitCell", forIndexPath: indexPath) as! VMTableViewCell
        
        let dataCell = savedVisits[indexPath.row]
        
        let lat = dataCell["latitude"] as! NSNumber
        let lon = dataCell["longitude"] as! NSNumber
        let entryDate = dataCell["entry_time"] as! String
        let exitDate = dataCell["exit_time"] as! String
        let hAccuracy = dataCell["accuracy"] as! NSNumber
        
        cell.coordinateLabel.text = "[Lat: \(lat), Lon: \(lon)]"
        cell.detailsLabel.text = "Entry Date: \(entryDate), Exit Time: \(exitDate) - Accuracy: \(hAccuracy)"
        
        //print(dataCell)
        
        return cell
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
