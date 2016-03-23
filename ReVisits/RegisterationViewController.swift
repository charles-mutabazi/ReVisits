//
//  RegisterationViewController.swift
//  CMO
//
//  Created by Charl on 1/31/16.
//  Copyright © 2016 Octans Corp. All rights reserved.
//

import UIKit
//pods
import Alamofire
import SwiftyJSON
import DeviceKit

class RegisterationViewController: UITableViewController {

    var gender = ""
    var age_range = ""
    @IBOutlet weak var display_name: UITextField!
    let UUID = UIDevice.currentDevice().identifierForVendor!.UUIDString
    let device = Device()
    let settings = Settings()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if userDefaults.objectForKey("vendorUUID") == nil {
            let saveButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: #selector(RegisterationViewController.saveButton))
            navigationItem.rightBarButtonItem = saveButton
            title = "Sign Up"
        }else{
            let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: #selector(RegisterationViewController.updateButton))
            self.navigationItem.leftBarButtonItem = doneButton
            title = "Update Info"
        }
        
        if userDefaults.objectForKey("gender")  != nil {
            gender = userDefaults.objectForKey("gender") as! String
        }
        
        if userDefaults.objectForKey("ageRange")  != nil {
            age_range = userDefaults.objectForKey("ageRange") as! String
        }
        
        if userDefaults.objectForKey("displayName") != nil{
            display_name.text = userDefaults.objectForKey("displayName") as? String
        }
        
        //device_uuid = NSUserDefaults.standardUserDefaults().objectForKey("vendorUUID") as! String
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func updateButton() {
        //let uuid = userDefaults.objectForKey("vendorUUID") as! String
        //let currentUsersUrl = baseUrl + "/users/" + uuid
        
        if Reachability.isConnectedToNetwork() == true {
            
            userDefaults.setObject(display_name.text!, forKey: "displayName")
            userDefaults.setObject(gender, forKey: "gender")
            userDefaults.setObject(age_range, forKey: "ageRange")
            userDefaults.setObject(device.systemVersion, forKey: "iosVersion")
            userDefaults.synchronize()
            
            let user_info = ["user": ["display_name":display_name.text!, "gender": gender, "age_range": age_range, "ios_version": device.systemVersion]]
            
            Alamofire.request(.PUT, settings.currentUsersUrl, parameters: user_info, encoding:.JSON)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveButton() {
        
        userDefaults.setObject(settings.UUID, forKey: "vendorUUID")
        userDefaults.setObject(display_name.text!, forKey: "displayName")
        userDefaults.setObject(gender, forKey: "gender")
        userDefaults.setObject(age_range, forKey: "ageRange")
        userDefaults.setObject(device.systemVersion, forKey: "iosVersion")
        userDefaults.synchronize()
        

        print("I am saving to the server...")
        let user_info = ["user": ["device_uuid":settings.UUID, "display_name":display_name.text!, "gender": gender, "age_range": age_range, "ios_version": device.systemVersion]]
        
        if Reachability.isConnectedToNetwork() == true {
            print("Not on the server... creating a new one....")
            Alamofire.request(.POST, self.settings.usersUrl, parameters: user_info, encoding:.JSON)
        }
        
        let mainView = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        self.presentViewController(mainView!, animated: true, completion:nil)
    }
    
    
    //awesome chazo
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if userDefaults.objectForKey("gender")  != nil {
            if cell.textLabel!.text == (userDefaults.objectForKey("gender") as! String) {
                cell.accessoryType = .Checkmark
            }
        }
        
        if userDefaults.objectForKey("ageRange") != nil{
            if cell.textLabel!.text == (userDefaults.objectForKey("ageRange") as! String){
                cell.accessoryType = .Checkmark
            }
        }
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let section = indexPath.section
        let numberOfRows = tableView.numberOfRowsInSection(section)
        
        for row in 0..<numberOfRows {
            if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: section)) {
                if cell.reuseIdentifier != "display_name" {
                    cell.accessoryType = row == indexPath.row ? .Checkmark : .None
                    let label = row == indexPath.row ? cell.textLabel?.text : nil
                    
                    //print(section)
                    if label != nil{
                        section == 1 ? (gender = label!) : (age_range = label!)
                    }
                }
            }
        }
    }
    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let section = indexPath.section
//        let row = indexPath.row
//        let cell = tableView.cellForRowAtIndexPath(indexPath) as UITableViewCell
    
//        if userDefaults.objectForKey("gender")  != nil {
//            if cell.textLabel!.text == (userDefaults.objectForKey("gender") as! String) {
//                cell.accessoryType = .Checkmark
//            }
//        }
//        
//        if userDefaults.objectForKey("ageRange") != nil{
//            if cell.textLabel!.text == (userDefaults.objectForKey("ageRange") as! String){
//                cell.accessoryType = .Checkmark
//            }
//        }
        
//        return cell
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
