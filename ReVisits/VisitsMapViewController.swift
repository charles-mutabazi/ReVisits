//
//  VisitsMapViewController.swift
//  CMO
//
//  Created by Charl on 3/13/16.
//  Copyright © 2016 Octans Corp. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import SwiftyJSON

import FBAnnotationClusteringSwift


//var savedLocations = [NSDictionary]()
class VisitsMapViewController: UIViewController {

    @IBOutlet var mapView: MKMapView!
    
    let clusteringManager = FBClusteringManager()
    
    let settings = Settings()
    let fileManager = NSFileManager.defaultManager()
    
    var savedLocations = [AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        mapView.delegate = self
        
        
        if (Reachability.isConnectedToNetwork()){
            print("from server....")
            getVisits()
        }else{
            if let locArray:[AnyObject] = settings.readMappingDataFile() as? [AnyObject] {
                savedLocations = locArray
                plotVisits()
            }
        
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func plotVisits(){
        
        var annoArray = [VisitAnnotations]()
        
        if savedLocations.count != 0 {
            for loadCount in 0 ..< savedLocations.count {
                let annot:VisitAnnotations = VisitAnnotations()
                
                let locationDict:AnyObject = savedLocations[loadCount] // loading array data at index
                let visitLat = locationDict["latitude"] as AnyObject? as! NSNumber
                let visitLon = locationDict["longitude"] as AnyObject? as! NSNumber
                let visitEntry = locationDict["entry_time"] as AnyObject? as! String
                let visitExit = locationDict["exit_time"] as AnyObject? as! String
                let visitAccuracy = locationDict["accuracy"] as AnyObject? as! NSNumber
                
                let visitLoc = CLLocation(latitude: visitLat.doubleValue, longitude: visitLon.doubleValue)
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "MMM dd, y, hh:mm:ss a"
                dateFormatter.AMSymbol = "AM"
                dateFormatter.PMSymbol = "PM"
                
                let exitDate = dateFormatter.dateFromString(visitExit)
                let entryDate = dateFormatter.dateFromString(visitEntry)
                
                //let calendar = NSCalendar.currentCalendar()
                //let startDate = calendar.startOfDayForDate(entryDate!)
                
                let timeinterval = exitDate!.timeIntervalSinceDate(entryDate!)
                
                annot.coordinate  = CLLocationCoordinate2D(latitude: visitLat.doubleValue, longitude: visitLon.doubleValue)
                annoArray.append(annot)
                
                annot.title = "Been here: " + timeAgoSince(exitDate!)
                annot.subtitle = "Time Spent: " + (stringFromTimeInterval(timeinterval) as String)
                
                //CIRCLE AROUND
                addRadiusCircle(visitLoc, accuracy: visitAccuracy)
        }
              
        }
        
        clusteringManager.addAnnotations(annoArray)
        fitMapViewToAnnotaionList(annoArray)
    }
    
    func getVisits(){
        
        //remove file mapping data file
        do{
            try fileManager.removeItemAtPath(mappingDataPath)
            print("file deleted....")
        }catch{
            print("Cannot delete file")
        }
        //re-create a new file
        settings.creatStoreFile(mappingDataPath, resourcePath: "MappingData")
        
        //let uuid = userDefaults.objectForKey("vendorUUID")
        //let userVisitsUrl = baseUrl + "/users/\(settings.UUID)/visits"
        //fetch data from the sever
        Alamofire.request(.GET, settings.userVisitsUrl)
            .responseJSON { (response) in
                
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling GET on /places")
                    print(response.result.error!)
                    return
                }
                
                let swiftyJsonVar = JSON(response.result.value!)
                if let resData = swiftyJsonVar.arrayObject  {
                    //add data to the file
                    self.settings.writeToMappingDataFile(mappingDataPath, data: resData)
                }
                if let locArray:[AnyObject] = self.settings.readMappingDataFile() as? [AnyObject] {
                    self.savedLocations = locArray
                    self.plotVisits()
                }
        }
        
    }
    
    //Add the circle around the coordinate
    func addRadiusCircle(location: CLLocation, accuracy: NSNumber){
        self.mapView.delegate = self
        let circle = MKCircle(centerCoordinate: location.coordinate, radius: accuracy as CLLocationDistance)
        self.mapView.addOverlay(circle)
    }
    
    //Zoom in to the available annotations
    func fitMapViewToAnnotaionList(annotations: [MKAnnotation]) -> Void {
        let mapEdgePadding = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        var zoomRect:MKMapRect = MKMapRectNull
        
        for index in 0..<annotations.count {
            let annotation = annotations[index]
            let aPoint:MKMapPoint = MKMapPointForCoordinate(annotation.coordinate)
            let rect:MKMapRect = MKMapRectMake(aPoint.x, aPoint.y, 0.1, 0.1)
            
            if MKMapRectIsNull(zoomRect) {
                zoomRect = rect
            } else {
                zoomRect = MKMapRectUnion(zoomRect, rect)
            }
        }
        
        mapView.setVisibleMapRect(zoomRect, edgePadding: mapEdgePadding, animated: true)
    }
    
    //Calculate time interval in hrs and minutes
    func stringFromTimeInterval(interval:NSTimeInterval) -> NSString {
        
        let ti = NSInteger(interval)
        
        //let ms = Int((interval % 1) * 1000)
        
        //let seconds = ti % 60
        
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        
        if hours > 0 && hours < 100 {
            return NSString(format: "%0.2d Hrs, %0.2d Mins",hours,minutes)
        }else if hours > 100 {
            return "Initial Point"
        }else{
            return NSString(format: "%0.2d Minutes",minutes)
        }
    }

}
