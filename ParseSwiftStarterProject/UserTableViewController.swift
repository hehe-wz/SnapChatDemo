//
//  UserTableViewController.swift
//  ParseStarterProject
//
//  Created by Techbow on 6/28/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class UserTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
  
  var usersArray = [PFUser]()
  var receiverUserIndex = 0
  var timer = NSTimer()
  
  @IBAction func logout(sender: AnyObject) {
    PFUser.logOut()
    timer.invalidate()
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func pickImage(sender: AnyObject) {
    var image = UIImagePickerController()
    image.delegate = self
    image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
    image.allowsEditing = false
    
    self.presentViewController(image, animated: true, completion: nil)
  }
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
    self.dismissViewControllerAnimated(true, completion: nil)
    
    let imageAcl = PFACL(user: PFUser.currentUser()!)
    imageAcl.setReadAccess(true, forUserId: usersArray[receiverUserIndex].objectId!)
    imageAcl.setWriteAccess(true, forUserId: usersArray[receiverUserIndex].objectId!)
    
    //upload to parse
    var imageToSend = PFObject(className:"image")
    imageToSend["imageFile"] = PFFile(name: "image.jpg", data: UIImageJPEGRepresentation(image, 0.5))
    imageToSend["senderUsername"] = PFUser.currentUser()?.username!
    imageToSend["receiverUsername"] = usersArray[receiverUserIndex].username!
    imageToSend.ACL = imageAcl
    
    imageToSend.saveInBackground()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    var query = PFUser.query()
    query?.whereKey("username", notEqualTo: PFUser.currentUser()!.username!)
    query?.findObjectsInBackgroundWithBlock({ (users, error) -> Void in
      if error == nil {
        // The find succeeded.
        println("Successfully retrieved \(users!.count) scores.")
        // Do something with the found objects
        if let users = users as? [PFUser] {
          for user in users {
            println(user.username!)
            self.usersArray = users
            self.tableView.reloadData()
          }
        }
      } else {
        // Log details of the failure
        println("Error: \(error!) \(error!.userInfo!)")
      }
    })
    timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "checkMessage", userInfo: nil, repeats: true)
  }
  
  func checkMessage() {
    println("checking messages")
    var query = PFQuery(className: "image")
    query.whereKey("receiverUsername", equalTo: PFUser.currentUser()!.username!)
    query.getFirstObjectInBackgroundWithBlock { (imageObject, error) -> Void in
      if error == nil {
        imageObject!["imageFile"]!.getDataInBackgroundWithBlock({ (data, error) -> Void in
          if error == nil {
            var senderUsername = imageObject!["senderUsername"] as! String
            
            var alert = UIAlertController(title: "You have a message", message: "Message From \(senderUsername), Tap OK to view", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
              var backgroundView = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
              backgroundView.backgroundColor = UIColor.blackColor()
              backgroundView.alpha = 0.8
              backgroundView.tag = 3
              self.view.addSubview(backgroundView)
              
              var displayedImageView = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
              displayedImageView.image = UIImage(data: data!)
              displayedImageView.contentMode = UIViewContentMode.ScaleAspectFit
              displayedImageView.tag = 3
              self.view.addSubview(displayedImageView)
              
              UIApplication.sharedApplication().beginIgnoringInteractionEvents()
              NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "hideMessage", userInfo: nil, repeats: false)
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
            self.timer.invalidate()
            imageObject!.deleteInBackground()
          }
        })
      } else {
        println("Error: \(error!) \(error!.userInfo!)")
      }
    }
  }
  
  func hideMessage() {
    for subView in self.view.subviews {
      if subView.tag == 3 {
        subView.removeFromSuperview()
      }
    }
    UIApplication.sharedApplication().endIgnoringInteractionEvents()
    timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "checkMessage", userInfo: nil, repeats: true)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    // #warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete method implementation.
    // Return the number of rows in the section.
    return self.usersArray.count
  }
  
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("userCell", forIndexPath: indexPath) as! UITableViewCell
    
    cell.textLabel?.text = usersArray[indexPath.row].username
    
    return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    receiverUserIndex = indexPath.row
    pickImage(self)
    
  }
}
