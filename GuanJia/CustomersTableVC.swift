//
//  CustomersTableVC.swift
//  GuanJia
//
//  Created by Liang Sun on 12/14/15.
//  Copyright © 2015 Lyon Sun. All rights reserved.
//

import UIKit
import Parse

class CustomersTableVC: UITableViewController {
    
    // MARK: Properties
    
    var customersObjects = [PFObject]()
    
    var shouldUpdateFromServer: Bool = true
    var allLoaded: Bool = false

    var customersCount: Int = 0
    var currentPage: Int = 0
    let itemPerPage: Int = 10
    
    // MARK: View Rendering
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.shouldUpdateFromServer {
            self.refreshLocalDataStoreFromServer()
        } else {
            self.shouldUpdateFromServer = true
        }
    }
    
    // MARK: Parse Querying
    
    func baseQuery() -> PFQuery {
        let query = PFQuery(className: "customers")
        
        query.limit = itemPerPage
        query.skip = currentPage * itemPerPage
        query.orderByDescending("updated_on")
        
        return query
    }
    
    func refreshLocalDataStoreFromServer() {
        self.baseQuery().fromLocalDatastore()
        self.baseQuery().findObjectsInBackgroundWithBlock { ( parseObjects, error) -> Void in
            if error == nil {
                print("Found \(parseObjects!.count) customers from server")
                
                self.customersCount += (parseObjects?.count)!
                self.allLoaded = parseObjects?.count < 10
                
                // First, unpin all existing objects
                PFObject.unpinAllInBackground(self.customersObjects, block: { (succeeded: Bool, error: NSError?) -> Void in
                    if error == nil {
                        // Pin all the new objects
                        PFObject.pinAllInBackground(parseObjects, block: { (succeeded: Bool, error: NSError?) -> Void in
                            if error == nil {
                                self.shouldUpdateFromServer = false
                                
                                if let objects = parseObjects {
                                    for object in objects {
                                        self.customersObjects.append(object)
                                    }
                                }
                                
                                // Once we've updated the local datastore, update the view with local datastore
                                self.tableView.reloadData()
                            } else {
                                print("Failed to pin objects")
                            }
                        })
                    }
                })
            } else {
                print("Couldn't get objects")
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return customersObjects.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseIdentifier = "cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CustomerTableViewCell

        // Configure the cell...
        
        let customer = customersObjects[indexPath.row]
        
        cell.nameLabel.text = customer["name"] as? String
        cell.phoneLabel.text = customer["phone"] as? String
        cell.addressLabel.text = "\(customer["province"]), \(customer["city"]), \(customer["district"]), \(customer["address_1"])"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // First figure out how many sections there are
        let lastSectionIndex = self.tableView!.numberOfSections - 1
        
        // Then grab the number of rows in the last section
        let lastRowIndex = self.tableView!.numberOfRowsInSection(lastSectionIndex) - 1
        
        if (indexPath.section == lastSectionIndex && indexPath.row == lastRowIndex) {
            // This is the last cell
            if !self.allLoaded {
                self.currentPage = Int(self.customersObjects.count / self.itemPerPage)
                
                self.refreshLocalDataStoreFromServer()
            } else {
                // all loaded
                print("all loaded \(self.customersCount)")            }
        }
    }
}
