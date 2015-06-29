//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {
  
  @IBOutlet var username: UITextField!
  
  @IBAction func signin(sender: AnyObject) {
    PFUser.logInWithUsernameInBackground(username.text, password:"techbow") {
      (user: PFUser?, error: NSError?) -> Void in
      if user != nil {
        // Do stuff after successful login.
        println("Log In")
        self.performSegueWithIdentifier("showUserSegue", sender: self)
      } else {
        
        var user = PFUser()
        user.username = self.username.text
        user.password = "techbow"
        
        user.signUpInBackgroundWithBlock {
          (succeeded: Bool, error: NSError?) -> Void in
          if let error = error {
            let errorString = error.userInfo?["error"] as? NSString
            // Show the errorString somewhere and let the user try again.
            println(errorString)
          } else {
            // Hooray! Let them use the app now.
            println("Sign Up")
            self.performSegueWithIdentifier("showUserSegue", sender: self)
          }
        }
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  override func viewDidAppear(animated: Bool) {
    if PFUser.currentUser()?.objectId != nil {
      self.performSegueWithIdentifier("showUserSegue", sender: self)
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}

