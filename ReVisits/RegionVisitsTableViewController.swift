//
//  VisitsTableViewController.swift
//  CMO
//
//  Created by Charl on 3/9/16.
//  Copyright © 2016 Octans Corp. All rights reserved.
//

import UIKit

class RegionVisitsTableViewController: UITableViewController {
    
    var savedPlaceVisits = [NSDictionary]()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let resultDictionary = NSMutableDictionary(contentsOfFile: regionMonitoringDataPath)
        savedPlaceVisits = resultDictionary?.objectForKey("place_visits") as! [NSDictionary]
        
        //print("Loaded LocationData.plist file is --> \(savedLocations)")
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        tableView.estimatedRowHeight = 44 // the height of the cell
        tableView.rowHeight = UITableViewAutomaticDimension
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        self.navigationItem.title = "Visited Regions - (\(savedPlaceVisits.count))"
        
        //check if the table is empty and display message
        if savedPlaceVisits.count == 0{
            let emptyLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
            
            emptyLabel.text = "No Data to Display!"
            emptyLabel.textColor = UIColor.grayColor()
            emptyLabel.textAlignment = .Center
            
            self.tableView.backgroundView = emptyLabel
            self.tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            return 0
        } else {
            return savedPlaceVisits.count
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:RMTableViewCell = tableView.dequeueReusableCellWithIdentifier("regionCell", forIndexPath: indexPath) as! RMTableViewCell

        let dataCell = savedPlaceVisits[indexPath.row]
        // Configure the cell...
        //cell.textLabel?.text = dataCell["place_id"] as? String
        
        let placeID = dataCell["place_id"] as! String
        let entryTime = dataCell["entry_time"] as! String
        let exitTime = dataCell["exit_time"] as! String
        
        cell.placeIdLabel.text = "Place ID: " + placeID
        cell.detailsLabel?.text = "Entry Date: " + entryTime + ", Exit Time: \(exitTime)"
        

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
