//
//  NewReviewViewController.swift
//  CMO
//
//  Created by Charl on 2/2/16.
//  Copyright © 2016 Octans Corp. All rights reserved.
//

import UIKit
import Alamofire

class NewReviewViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var reviewDescriptionTextView: UITextView!
    @IBOutlet weak var custToolbalbarView: UIView!
    @IBOutlet weak var myToolbarBottomConstraint: NSLayoutConstraint!
    
    let settings = Settings()
    var placeId:String!
    var placeName:String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.hidden = true
        self.navigationItem.title = placeName
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewReviewViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewReviewViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)

        // Do any additional setup after loading the view.
        //self.reviewDescriptionTextView.scrollRangeToVisible(NSMakeRange(0, 0))
        reviewDescriptionTextView.text = "Enter a review here..."
        reviewDescriptionTextView.textColor = UIColor.lightGrayColor()
        
        reviewDescriptionTextView.becomeFirstResponder()
        reviewDescriptionTextView.selectedTextRange = reviewDescriptionTextView.textRangeFromPosition(reviewDescriptionTextView.beginningOfDocument, toPosition: reviewDescriptionTextView.beginningOfDocument)
        
        //keyboardToolbar()
        
        print("This is the place Id: \(placeId)")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //To add toolbar inputAccessory View
    func keyboardToolbar() {
        let numberToolbar = UIToolbar(frame: CGRectMake(0, 0, self.view.frame.size.width, 50))
        numberToolbar.barStyle = UIBarStyle.Default
        
        numberToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)]
            //UIBarButtonItem(title: "Submit", style: UIBarButtonItemStyle.Plain, target: self, action: "keyboardDoneButtonTapped")
        
        numberToolbar.sizeToFit()
        reviewDescriptionTextView.inputAccessoryView = numberToolbar
    }
    
    @IBAction func submitButon(sender: AnyObject) {
        print("Submit Button Tapped!")
        let reviewText = reviewDescriptionTextView.text
        let reviewData = ["body": reviewText, "user_id": settings.UUID, "place_id": placeId]
        
        if Reachability.isConnectedToNetwork() == true {
            
            Alamofire.request(.POST, settings.placesUrl + placeId + "/reviews", parameters: ["review" : reviewData], encoding:.JSON)
                .responseJSON { response in
                    if response.result.error == nil {
                        print("Successfull Added")
                        self.reviewDescriptionTextView.text = ""
                        self.navigationController?.popViewControllerAnimated(true)
                        
                    }else {
                        print("Error..... \(response.result.error)")
                    }
            }
        }
    }
    
    //Keyboard like toolbar
    func keyboardWillShow(notification: NSNotification) {
        self.myToolbarBottomConstraint.constant = 0
        let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
        self.myToolbarBottomConstraint.constant += keyboardSize!.height
//        UIView.animateWithDuration(0.1, animations: { () -> Void in
//            
//            self.custToolbalbarView.layoutIfNeeded()
//        })
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        UIView.animateWithDuration(0.3){
            self.myToolbarBottomConstraint.constant = 0
            self.custToolbalbarView.layoutIfNeeded()
        }
    }
    
    //Text view delegates
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        let currentText:NSString = textView.text
        let updatedText = currentText.stringByReplacingCharactersInRange(range, withString:text)
        
        if updatedText.isEmpty {
            textView.text = "Enter a review here..."
            textView.textColor = UIColor.lightGrayColor()
            
            textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
            
            return false
            
        }else if textView.textColor == UIColor.lightGrayColor() && !text.isEmpty {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
        
        return true
    }
    
    func textViewDidChangeSelection(textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGrayColor() {
                textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
            }
        }
    }
    // ENDOF - Textview Delegates

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
