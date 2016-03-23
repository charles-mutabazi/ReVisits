//
//  UserDetailsTableViewController.swift
//  CMO
//
//  Created by Charl on 2/26/16.
//  Copyright © 2016 Octans Corp. All rights reserved.
//

import UIKit

class UserDetailsTableViewController: UITableViewController {
    
    @IBOutlet weak var displayName: UILabel!
    var gender = ""
    var age_range = ""
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        displayName.text = userDefaults.objectForKey("displayName") as? String
        gender = userDefaults.objectForKey("gender") as! String
        age_range = userDefaults.objectForKey("ageRange") as! String
        
        tableView.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if cell.reuseIdentifier == "gender" {
            cell.detailTextLabel?.text = gender
        }
        
        if cell.reuseIdentifier == "age_range" {
            cell.detailTextLabel?.text = age_range
        }
        
        if cell.reuseIdentifier == "editInfo" {
            dispatch_async(dispatch_get_main_queue(), {
                if Reachability.isConnectedToNetwork() == false {
                    cell.userInteractionEnabled = false
                    cell.textLabel?.text = "Edit Info (No Internet!)"
                    cell.textLabel?.textColor = UIColor.lightGrayColor()
                }
            })
        }
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
