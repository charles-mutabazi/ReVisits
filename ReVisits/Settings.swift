//
//  Settings.swift
//  CMO
//
//  Created by Charl on 3/16/16.
//  Copyright © 2016 Octans Corp. All rights reserved.
//

import Foundation
import Alamofire

let rootPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, .UserDomainMask, true)[0]
let url = NSURL(string: rootPath)
let visitsDataPath = (url?.URLByAppendingPathComponent("VisitsData.plist").absoluteString)!
let regionMonitoringDataPath = (url?.URLByAppendingPathComponent("RegionMonitoringData.plist").absoluteString)!
let regionsDataPath = (url?.URLByAppendingPathComponent("MonitoredRegions.plist").absoluteString)!
let mappingDataPath = (url?.URLByAppendingPathComponent("MappingData.plist").absoluteString)!

let baseUrl = NSBundle.mainBundle().objectForInfoDictionaryKey("Base API") as! String
let userDefaults = NSUserDefaults.standardUserDefaults()

class Settings {
    
    let fileManager = NSFileManager.defaultManager()
    
    let userVisitsUrl:String!
    let placesUrl:String!
    let usersUrl:String!
    let placeVisitsUrl:String!
    let UUID:String!
    let currentUsersUrl:String!
    let visitsUrl:String!
    
    init() {
        
        UUID = UIDevice.currentDevice().identifierForVendor!.UUIDString
        placesUrl = baseUrl + "/places/"
        usersUrl = baseUrl + "/users/"
        visitsUrl = baseUrl + "/visits/"
        placeVisitsUrl = baseUrl + "/place_visits/"
        userVisitsUrl = baseUrl + "/users/\(UUID)/visits"
        currentUsersUrl = baseUrl + "/users/" + UUID
        
    }
    
    func creatStoreFile(filePath: String, resourcePath: String){
        //CREATE FILE For VISITS
        if (!fileManager.fileExistsAtPath(filePath)) {
            let plistPathInBundle = NSBundle.mainBundle().pathForResource(resourcePath, ofType: "plist")!
            
            do{
                try fileManager.copyItemAtPath(plistPathInBundle, toPath: filePath)
                print("File did not exist! Default copied... \(resourcePath)")
            }
            catch{
                print("error copying plist!")
            }
        }else{
            print("\(resourcePath).plist exists... the path to file is ===> \(filePath)")
            // use this to delete file from documents directory
            //fileManager.removeItemAtPath(path, error: nil)
        }
    }
    
    func writeTofile(filePath:String, data:AnyObject, key:String){
        let dict = NSMutableDictionary(contentsOfFile: filePath)
        
        //Convert AnyObject to NSMutableArray
        let savedVisits:NSArray = (dict?.objectForKey(key))! as! NSArray
        let dataArray = (savedVisits as! NSMutableArray) as NSMutableArray
        
        
        //add dictionary to array
        dataArray.addObject(data)
        
        //set the new array for location key
        dict!.setObject(savedVisits, forKey: key)
        
        //writing to GameData.plist
        dict!.writeToFile(filePath, atomically: false)
    }
    
    //writting to mapping data file
    func writeToMappingDataFile(filePath:String, data:AnyObject){
        let dict = NSMutableArray(contentsOfFile: filePath)
        
        //add dictionary to array
        dict!.addObject(data)
        
        //writing to GameData.plist
        dict!.writeToFile(filePath, atomically: false)
    }
    
    func readMappingDataFile() -> AnyObject? {
        //var dict = [NSDictionary]()
        let resultDictionary = NSMutableArray(contentsOfFile: mappingDataPath)
        let savedLocations = (resultDictionary?.objectAtIndex(0))!
        
        //print("Loaded LocationData.plist file is --> \(savedLocations)")
        if savedLocations.count > 0 {
            return savedLocations
        }else{
            return nil
        }
        
    }
    
    //Upload data saved on a file
    func uploadFileData(filePath:String, key:String, urlPath:String, fileName:String){
        let resultDictionary = NSMutableDictionary(contentsOfFile: filePath)
        let savedLocations = resultDictionary?.objectForKey(key) as! [AnyObject]
        
        if savedLocations.count > 0 {
            Alamofire.request(.POST, urlPath, parameters: [key : savedLocations], encoding:.JSON)
                .responseJSON { response in
                    do{
                        try self.fileManager.removeItemAtPath(filePath)
                        print("file deleted....")
                    }catch{
                        print("Cannot delete file")
                    }
                    
                    self.creatStoreFile(filePath, resourcePath: fileName)
                    //self.tableView.reloadData()
            }
            
        }else{
            print("Nothing uploaded.... no data")
        }
    }
    
}
