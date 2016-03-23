//
//  PlacesTableViewController.swift
//  CMO
//
//  Created by Charl on 1/29/16.
//  Copyright © 2016 Octans Corp. All rights reserved.
//

import UIKit
//pods
import Alamofire
import SwiftyJSON
import Haneke

class PlacesTableViewController: UITableViewController{
    
    var places = []
    let settings = Settings()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //Upload saved data to server
        if Reachability.isConnectedToNetwork() == true {
            //Clear all the caches
            NSURLCache.sharedURLCache().removeAllCachedResponses()
            
            //RegionMonitored data
            settings.uploadFileData(regionMonitoringDataPath, key: "place_visits", urlPath: settings.placeVisitsUrl, fileName: "RegionMonitoringData")
            
            //cirrent device captured visists
            settings.uploadFileData(visitsDataPath, key: "visits", urlPath: settings.visitsUrl, fileName: "VisitsData")
            
        }
        
        //make a request
        getPlaces()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 74.0 // the height of the cell
        tableView.rowHeight = UITableViewAutomaticDimension
        
        //pull to refresh
        self.refreshControl?.addTarget(self, action: #selector(PlacesTableViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh(sender: UIRefreshControl){
        
        if Reachability.isConnectedToNetwork() == true {
            NSURLCache.sharedURLCache().removeAllCachedResponses()
        }
        
        //cacheHandling()
        getPlaces()
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return places.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:PlacesTableViewCell = tableView.dequeueReusableCellWithIdentifier("placesCell", forIndexPath: indexPath) as! PlacesTableViewCell

        //let downloader = ImageDownloader()
        
        // Configure the cell...
        let dict = places[indexPath.row]
        cell.placeTitleLabel.text = dict["name"] as? String
        cell.placeDescriptionLabel.text = dict["description"] as? String
        cell.reviewCounterLabel.text = "\(dict["reviews"]!!.count) Reviews"
        
        let imgUrl = dict["image_url_large"] as! String
        
        let url = NSURL(string: baseUrl + imgUrl)
        cell.placeImage.hnk_setImageFromURL(url!)
        
        return cell
    }
    @IBAction func backToHomeBtn(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let path = self.tableView.indexPathForSelectedRow!
        
        let detailViewController = segue.destinationViewController as! PlaceTableViewController
        detailViewController.placeObj = self.places[path.row] as! NSDictionary
        
        
        //detailViewController.currentLocation = currLoc
    }

    //Get all places
    func getPlaces(){
        
        //Request with caching policy
        let request = NSMutableURLRequest(URL: NSURL(string: Settings().placesUrl)!, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 20)
        Alamofire.request(request)
            .responseJSON { (response) in
                let cachedURLResponse = NSCachedURLResponse(response: response.response!, data: (response.data! as NSData), userInfo: nil, storagePolicy: .Allowed)
                NSURLCache.sharedURLCache().storeCachedResponse(cachedURLResponse, forRequest: response.request!)
                
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling GET on /places")
                    print(response.result.error!)
                    return
                }
                
                let swiftyJsonVar = JSON(data: cachedURLResponse.data)
                if let resData = swiftyJsonVar["places"].arrayObject  {
                    // handle the results as JSON, without a bunch of nested if loops
                    self.places = resData
                    //print(self.places)
                }
                if self.places.count > 0 {
                    self.tableView.reloadData()
                }
        }

    }
    
}
