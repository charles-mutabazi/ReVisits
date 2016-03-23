//
//  AppDelegate.swift
//  CMO
//
//  Created by Charl on 1/28/16.
//  Copyright © 2016 Octans Corp. All rights reserved.
//

import UIKit
import CoreLocation

//pods
import Alamofire
import SwiftyJSON
import DeviceKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    var entryTime = ""
    var exitTime = ""
    var startTime:CFAbsoluteTime!
    
    let fileManager = NSFileManager.defaultManager()
    var myLocationManager = CLLocationManager()
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var currentLocation:CLLocation!
    
    
    var window: UIWindow?
    let settings = Settings()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        
        //Needed to activate notification
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil))
        
        let uuid = userDefaults.objectForKey("vendorUUID")
        
        //userDefaults.setObject("B184D31A-449A-40C3-A795-331C17C6ECC6", forKey: "vendorUUID")
        
        //Location Related
        myLocationManager.delegate = self
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        myLocationManager.allowsBackgroundLocationUpdates = true //very important
        
        alertForAuthorization()
        //writeToFile() // write the places to file
        //startMonitoringRegions() // read from the file and configure regions
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let signUpViewController = storyboard.instantiateViewControllerWithIdentifier("SignUpView") as! UINavigationController
        let mainView = storyboard.instantiateInitialViewController()
        
        if uuid == nil {
            //go to signup page
            self.window?.rootViewController = signUpViewController
        }else{
            //check for internet availability
            if Reachability.isConnectedToNetwork() == true {
                //let currentUsersUrl = baseUrl + "/users/" + (uuid as! String)
                Alamofire.request(.GET, settings.usersUrl)
                    .responseJSON { response in
                        guard response.result.error == nil else {
                            print(response.result.error!)
                            return
                        }
                        let swiftyJsonVar = JSON(response.result.value!)
                        
                        //print(swiftyJsonVar)
                        
                        //if the user exists
                        let users = swiftyJsonVar["users"].arrayObject
                        
                        //print("USER IDS::::::: \(userIds)")
                        var user_exist:Bool!
                        
                        for id in users! {
                            let user_ids = id["_id"] as! String
                            if user_ids == uuid as! String {
                                user_exist = true
                            }else{
                                user_exist = false
                            }
                        }
                        
                        if user_exist == false {
                            let gender = self.userDefaults.objectForKey("gender") as! String
                            let ageRange = self.userDefaults.objectForKey("ageRange") as! String
                            let displayName = self.userDefaults.objectForKey("displayName") as! String
                            let device_uuid = self.userDefaults.objectForKey("vendorUUID") as! String
                            
                            let user_info = ["user": ["device_uuid": device_uuid, "display_name":displayName, "gender": gender, "age_range": ageRange, "ios_version": Device().systemVersion]]
                            
                            print("Not on the server... creating a new one....")
                            Alamofire.request(.POST, self.settings.usersUrl, parameters: user_info, encoding:.JSON)
                        }
                }
            }
            
            self.window?.rootViewController = mainView
        }
        
        //Create default files
        settings.creatStoreFile(regionMonitoringDataPath, resourcePath: "RegionMonitoringData")
        settings.creatStoreFile(visitsDataPath, resourcePath: "VisitsData")
        settings.creatStoreFile(mappingDataPath, resourcePath: "MappingData")
        //settings.creatStoreFile(regionsDataPath, resourcePath: "MonitoredRegions")
        
        //UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //write the places to the file for offline monitoring
    func saveAndMonitorRegions(){
        
        Alamofire.request(.GET, settings.placesUrl)
            .responseJSON { response in
                
                guard response.result.error == nil else {
                    print(response.result.error!)
                    return
                }
                let swiftyJsonVar = JSON(response.result.value!)
                if let resData:NSArray? = swiftyJsonVar["places"].arrayObject  {
                    resData!.writeToFile(regionsDataPath, atomically: true)
                }
                
                self.startMonitoringRegions()
        }
    }
    
    // set the regions for monitoring
    func startMonitoringRegions(){
        let readArray:NSArray? = NSArray(contentsOfFile: regionsDataPath)

        if let array = readArray {
            for place in array {
                
                let currentReg = CLCircularRegion(center: CLLocationCoordinate2D(latitude: (place["latitude"] as! NSString).doubleValue, longitude: (place["longitude"] as! NSString).doubleValue), radius: 200, identifier: (place["_id"] as! String))
                
                //Check if the current coordinate is in the region
                if currentReg.containsCoordinate((myLocationManager.location!.coordinate)) {
                    print("Currently in the region.... ")
                    entryTime = timeStamp()
                }
                
                myLocationManager.startMonitoringForRegion(currentReg)
            }
        } else {
            print("cannot read the file!")
        }
        
    }
    
    func startMonioringVisits() {
        myLocationManager.startMonitoringVisits()
        print("Visit monitoring started....")
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        entryTime = ""
        entryTime = timeStamp()
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        exitTime = timeStamp()
        exitedRegion(entryTime, exitTimeStamp: exitTime, placeId: region.identifier)
        
        entryTime = ""
        exitTime = ""
    }
    
    func isArrivalVisit(visit: CLVisit) -> Bool {
        return visit.departureDate.isEqual(NSDate.distantFuture())
    }
    
    
    func exitedRegion(entryTimeStamp: String, exitTimeStamp: String, placeId: String){
        //Notifications.display("Now outside: " + placeId)
        
        //let uuid = userDefaults.objectForKey("vendorUUID") as! String
        let placeVisits = ["exit_time": exitTimeStamp, "entry_time": entryTimeStamp, "place_id": placeId, "user_id": settings.UUID]
        
        settings.writeTofile(regionMonitoringDataPath, data: placeVisits, key: "place_visits")

    }
    
    //get timestamp
    func timeStamp() -> String {
        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .MediumStyle)
        return timestamp
    }
    
    //Did Visit area - Delegate
    func locationManager(manager: CLLocationManager, didVisit visit: CLVisit) {
        if !isArrivalVisit(visit){
            recordVisitData(visit)
        }
    }
    
    // record the visit
    func recordVisitData(visit: CLVisit) {
        
        let arrDate = NSDateFormatter.localizedStringFromDate(visit.arrivalDate, dateStyle: .MediumStyle, timeStyle: .MediumStyle)
        let depDate = NSDateFormatter.localizedStringFromDate(visit.departureDate, dateStyle: .MediumStyle, timeStyle: .MediumStyle)
        //let uuid = userDefaults.objectForKey("vendorUUID") as! String
        
        let visitData = ["longitude": visit.coordinate.longitude, "latitude": visit.coordinate.latitude, "entry_time": arrDate, "exit_time" : depDate, "accuracy": visit.horizontalAccuracy, "user_id": settings.UUID]
        
        settings.writeTofile(visitsDataPath, data: visitData, key: "visits")
    }
    
    //ERROR HANDLING
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location Manager failed with the following error: \(error)")
    }
    
//    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        currentLocation = locations.last
//        
//        myLocationManager.stopUpdatingLocation()
//        
//    }
    
    //alert if the no authorization is provided
    private func alertForAuthorization(){
        let authState = CLLocationManager.authorizationStatus()
        switch authState {
        case .AuthorizedAlways:
            //myLocationManager.startUpdatingLocation()
            saveAndMonitorRegions() //for monitoring regions
            startMonioringVisits()
        case .NotDetermined:
            myLocationManager.requestAlwaysAuthorization()
        case .AuthorizedWhenInUse, .Restricted, .Denied:
            dispatch_async(dispatch_get_main_queue(), {
                let alertController = UIAlertController(
                    title: "Background Location Access Disabled",
                    message: "In order to get the most from this app, please open this app's settings and set location access to 'Always'.",
                    preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                alertController.addAction(cancelAction)
                
                let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
                    if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                        UIApplication.sharedApplication().openURL(url)
                    }
                }
                alertController.addAction(openAction)
                
                self.window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
            })
            
        }
    }
    

}

