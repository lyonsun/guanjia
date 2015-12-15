//
//  OrdersTableVC.swift
//  GuanJia
//
//  Created by Liang Sun on 12/15/15.
//  Copyright © 2015 Lyon Sun. All rights reserved.
//

import UIKit
import Parse
// import ParseUI

class OrdersTableVC: UITableViewController { // , PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
    
    // MARK: Properties
    
    var orderObjects = [PFObject]()
    
    var currentPage = 0

    // MARK: View Actions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        
//        if PFUser.currentUser() == nil {
//            let logInViewController = PFLogInViewController()
//            
//            logInViewController.delegate = self
//            
//            let signUpViewController = PFSignUpViewController()
//            
//            signUpViewController.delegate = self
//            
//            logInViewController.signUpController = signUpViewController
//            
//            self.presentViewController(logInViewController, animated: true, completion: nil)
//        } else {
        
//            self.fetchAllObjectsFromLocalDataStore()
            self.fetchAllObjectsFromParse()
            
//        }
    }
    
    // Querying Data
    
    func fetchAllObjectsFromLocalDataStore() {
        
        print("current Page: \(self.currentPage)")
        
        let query = PFQuery(className: "orders")
        query.fromLocalDatastore()
        query.orderByDescending("final_delivery_time")
        query.limit = (self.currentPage + 1) * 10
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) orders.")
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        self.orderObjects.append(object)
                        print("Name: \(object.objectForKey("buyer_name"))")
                    }
                }
                
                self.tableView.reloadData()
            } else {
                print("Error: \(error?.userInfo)")
            }
        }
    }
    
    func fetchAllObjectsFromParse() {
        
        PFObject.unpinAllObjectsInBackgroundWithBlock { (success, error) -> Void in
            if error == nil {
                print("Unpin success")
            } else {
                print("Error: \(error!.userInfo)")
            }
        }
        let query = PFQuery(className: "orders")
        query.orderByDescending("final_delivery_time")
        query.limit = 10
        query.skip = self.currentPage * 10
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                PFObject.pinAllInBackground(objects, block: nil)
                print("fetchAllObjectsFromParse: \(objects!.count) orders")
//                if let objects = objects {
//                    for object in objects {
//                        print("Name: \(object.objectForKey("buyer_name"))")
//                    }
//                }
                
                self.fetchAllObjectsFromLocalDataStore()
                
                print("fetchAllObjectsFromLocalDataStore in fetchAllObjectsFromParse: \(objects!.count) orders")
//                if let objects = objects {
//                    for object in objects {
//                        print("Name: \(object.objectForKey("buyer_name"))")
//                    }
//                }
            } else {
                print("Error: \(error?.userInfo)")
            }
        }
    }
    
    // Parse UI
    /*
    func logInViewController(logInController: PFLogInViewController, shouldBeginLogInWithUsername username: String, password: String) -> Bool {
        if !username.isEmpty || !password.isEmpty {
            return true
        }
        return false
    }
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func logInViewController(logInController: PFLogInViewController, didFailToLogInWithError error: NSError?) {
        print("Failed to log in ...")
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, shouldBeginSignUp info: [NSObject : AnyObject]) -> Bool {
        if let password = info["password"] as? String {
            return password.utf16.count >= 8
        }
        return false
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didFailToSignUpWithError error: NSError?) {
        print("Failed to sign up ...")
    }
    
    func signUpViewControllerDidCancelSignUp(signUpController: PFSignUpViewController) {
        print("User canceled sign up")
    }
    */

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.orderObjects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! OrderTableViewCell

        // Configure the cell...
        
        let order: PFObject = self.orderObjects[indexPath.row]
        
        cell.buyerLabel?.text = order["buyer_name"] as? String
        cell.commentLabel?.text = order["comments"] as? String
        cell.trackingNumberLabel?.text = order["tracking_number"] as? String
        cell.deliveryDateLabel?.text = order["final_delivery_time"] as? String

        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        // First figure out how many sections there are
        let lastSectionIndex = self.tableView!.numberOfSections - 1
        
        // Then grab the number of rows in the last section
        let lastRowIndex = self.tableView!.numberOfRowsInSection(lastSectionIndex) - 1
        
        if (indexPath.section == lastSectionIndex && indexPath.row == lastRowIndex) {
            // This is the last cell
            print("objects count: \(self.orderObjects.count)")
            
            self.currentPage = Int(self.orderObjects.count / 10)
            print("new current page: \(self.currentPage)")
            
            
//            self.fetchAllObjectsFromLocalDataStore()
            self.fetchAllObjectsFromParse()
        }
    }
    
}
