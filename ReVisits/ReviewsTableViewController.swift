//
//  ReviewsTableViewController.swift
//  CMO
//
//  Created by Charl on 2/2/16.
//  Copyright © 2016 Octans Corp. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


class ReviewsTableViewController: UITableViewController {

    @IBOutlet weak var newRevBtn: UIBarButtonItem!
    
    var placeId:String!
    var placeName:String!
    var reviews = []
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if Reachability.isConnectedToNetwork() == false {
            newRevBtn.enabled = false
        }
        
        getPlaceReviews()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = placeName
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        tableView.estimatedRowHeight = 71.0 // the height of the cell
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.reloadData()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        var numOfSections = 0
        
        if reviews.count == 0 {
            let emptyLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
            numOfSections = 0
            if Reachability.isConnectedToNetwork() == false {
               emptyLabel.text = "Connect to Internet first!"
            }else{
                emptyLabel.text = "No Reviews!"
            }
            emptyLabel.textColor = UIColor.grayColor()
            emptyLabel.textAlignment = .Center
            
            self.tableView.backgroundView = emptyLabel
            self.tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            
        } else {
            numOfSections = 1
            self.tableView.backgroundColor = UIColor.whiteColor()
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            
        }
        
        return numOfSections
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return reviews.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:ReviewsTableViewCell = tableView.dequeueReusableCellWithIdentifier("reviewCell", forIndexPath: indexPath) as! ReviewsTableViewCell

        // Configure the cell...
        
        let cellData = reviews[indexPath.row]
        
        let user = cellData["user"]!!["display_name"] as! String
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ'"
        
        let timeAdded = dateFormatter.dateFromString(cellData["created_at"] as! String)
        
        cell.reviewTitleLabel.text = user
        cell.reviewDateLabel.text = timeAgoSince(timeAdded!)
        cell.reviewDescriptionLabel.text = cellData["body"] as? String
        return cell
    }
    
    func getPlaceReviews(){
        //Request with caching policy
        //let request = NSMutableURLRequest(URL: NSURL(string: Settings().placesUrl + placeId + "/reviews")!, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 5)
        
        //print( Settings().placesUrl + placeId + "/visits")
        Alamofire.request(.GET, Settings().placesUrl + placeId + "/reviews")
            .responseJSON { (response) in
                //let cachedURLResponse = NSCachedURLResponse(response: response.response!, data: (response.data! as NSData), userInfo: nil, storagePolicy: .Allowed)
               // NSURLCache.sharedURLCache().storeCachedResponse(cachedURLResponse, forRequest: response.request!)
                
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling GET \(response.result.error!)")
                    return
                }
                
                let swiftyJsonVar = JSON(response.result.value!)
                if let resData = swiftyJsonVar["reviews"].arrayObject  {
                    // handle the results as JSON, without a bunch of nested if loops
                    self.reviews = resData
                    //print(self.reviews)
                }
                if self.reviews.count > 0 {
                    
                    self.tableView.reloadData()
                }
        }
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let newReviewController = segue.destinationViewController as! NewReviewViewController
        newReviewController.placeId = placeId
        newReviewController.placeName = placeName
    }


}
