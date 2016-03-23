//
//  PlaceTableViewController.swift
//  CMO
//
//  Created by Charl on 1/29/16.
//  Copyright © 2016 Octans Corp. All rights reserved.
//

import UIKit
import CoreLocation
//import AddressBook

import MapKit
import Haneke

class PlaceTableViewController: UITableViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var placeDescriptionLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var likeCounterLabel: UILabel!
    @IBOutlet weak var reviewCounterLabel: UILabel!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var distanceAway: UILabel!
    
    var locationManager = CLLocationManager()
    var currentLocation:CLLocation!
    
    var placeObj:NSDictionary = NSDictionary()
    var placeLocation:CLLocation!
    
    var placeAdress:String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //locationManager.requestLocation()
        
        let placeTitle = placeObj["name"] as? String
        let placeDescription = placeObj["description"] as? String
        let placeReviewCounter = placeObj["reviews"]?.count
        placeAdress = placeObj["address"] as? String
        
        let latitudeValue = Double(placeObj["latitude"] as! String)
        let longitudeValue = Double(placeObj["longitude"] as! String)
        
        let imgUrl = placeObj["image_url_large"] as! String
        
        let url = NSURL(string: baseUrl + imgUrl)
        placeImage.hnk_setImageFromURL(url!)
        
        //print(placeObj)
        
        mapView.delegate = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 237 // the height of the cell
        
        self.navigationItem.title = placeTitle
        placeDescriptionLabel.text = placeDescription
        reviewCounterLabel.text = "\(placeReviewCounter!) Reviews"
        
        
        //Zoom in the place location
        placeLocation = CLLocation(latitude: latitudeValue!, longitude: longitudeValue!)
        centerMap(placeLocation, radius: 600)
        
        //Add the annotation to the map
        let location2D = CLLocationCoordinate2D(latitude: latitudeValue!, longitude: longitudeValue!)
        addAnnotation(location2D, title: placeTitle!, address: placeAdress!)
        
        //self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil) //to change the back button title
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        
        let distanceBtn:CLLocationDistance = currentLocation.distanceFromLocation(placeLocation)/1000
        let distFormated = Double(round(distanceBtn*100)/100)
        self.distanceAway.text = distFormated.description
        //print("Distance Between......\(distFormated)")
        locationManager.stopUpdatingLocation()
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Something is not right.......\(error)")
    }
    
    @IBAction func likeButton(sender: AnyObject) {
        likeBtn.tintColor = UIColor.redColor()
    }

    @IBAction func takeMeThereBtn(sender: AnyObject) {
//        let geoCoder = CLGeocoder()
//        
//        let addressString = "\(address.text) \(city.text) \(state.text) \(zip.text)"
//        
//        geoCoder.geocodeAddressString(addressString, completionHandler:
//            {(placemarks: [AnyObject]!, error: NSError!) in
//                
//                if error != nil {
//                    println("Geocode failed with error: \(error.localizedDescription)")
//                } else if placemarks.count > 0 {
//                    let placemark = placemarks[0] as! CLPlacemark
//                    let location = placemark.location
//                    self.coords = location.coordinate
//                    
//                    self.showMap()
//                    
//                }
//        })
    }
    
    
//    func showMap() {
//        let addressDict =
//        [kABPersonAddressStreetKey as NSString: address.text,
//            kABPersonAddressCityKey: city.text,
//            kABPersonAddressStateKey: state.text,
//            kABPersonAddressZIPKey: zip.text]
//        
//        let place = MKPlacemark(coordinate: coords!,
//            addressDictionary: addressDict)
//        
//        let mapItem = MKMapItem(placemark: place)
//        
//        let options = [MKLaunchOptionsDirectionsModeKey:
//            MKLaunchOptionsDirectionsModeDriving]
//        
//        mapItem.openInMapsWithLaunchOptions(options)
//    }
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    //center the map
    func centerMap(location: CLLocation, radius: CLLocationDistance){
        let regionRadius: CLLocationDistance = radius
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        let region = MKCoordinateRegionMakeWithDistance(center, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(region, animated: true)
    }
    
    func addAnnotation(location:CLLocationCoordinate2D, title:String, address:String){
        
        let anotation = MKPointAnnotation()
        anotation.coordinate = location
        anotation.title = title
        anotation.subtitle = address
        mapView.addAnnotation(anotation)
    }
    
//    func getPlaceName(completion: (answer: String?) -> Void) {
//        
//        let coordinates = placeLocation
//        
//        CLGeocoder().reverseGeocodeLocation(coordinates, completionHandler: {(placemarks, error) -> Void in
//            if (error != nil) {
//                print("Reverse geocoder failed with an error" + error!.localizedDescription)
//                completion(answer: "")
//            } else if placemarks!.count > 0 {
//                let pm = placemarks![0] as CLPlacemark
//                completion(answer: displayLocaitonInfo(pm))
//            } else {
//                print("Problems with the data received from geocoder.")
//                completion(answer: "")
//            }
//        })
//        
//    }
    
//     //1
//    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
//        if let annotation = annotation as? VistedPlace {
//            let identifier = "pin"
//            //var view: MKPinAnnotationView
//            var view: MKAnnotationView
//            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
//                as? MKPinAnnotationView { // 2
//                    dequeuedView.annotation = annotation
//                    view = dequeuedView
//            } else {
//                // 3
//                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//                view.canShowCallout = true
//                view.calloutOffset = CGPoint(x: -5, y: 5)
//                view.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure) as UIView
//                view.image = UIImage(named: "purple_dot")
//            }
//            return view
//        }
//        return nil
//    }

/*
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 6
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:PlaceTableViewCell = tableView.dequeueReusableCellWithIdentifier("placeCell", forIndexPath: indexPath) as! PlaceTableViewCell

        // Configure the cell...

        return cell
    }
*/


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
        let reviewsController = segue.destinationViewController as! ReviewsTableViewController
        reviewsController.placeId = placeObj["_id"] as! String
        reviewsController.placeName = placeObj["name"] as! String
        
    }


}
