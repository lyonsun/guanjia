//
//  OrdersTableVC.swift
//  GuanJia
//
//  Created by Liang Sun on 12/15/15.
//  Copyright © 2015 Lyon Sun. All rights reserved.
//

import UIKit
import Parse

class OrdersTableVC: UITableViewController {
    
    // MARK: Properties
    
    var ordersObjects = [PFObject]()
    
    var shouldUpdateFromParse: Bool = true
    var allLoaded: Bool = false
    
    var currentPage: Int = 0
    let itemPerPage: Int = 10
    
    // MARK: View Rendering
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.shouldUpdateFromParse && !self.allLoaded {
            self.fetchObjectsFromParse()
        }
    }
    
    // MARK: Parse Querying
    
    func baseQuery() -> PFQuery {
        let query = PFQuery(className: "orders")
        
        query.limit = itemPerPage
        query.skip = currentPage * itemPerPage
        query.orderByDescending("final_delivery_time")
        
        return query
    }
    
    func fetchObjectsFromParse() {
        self.baseQuery().fromLocalDatastore()
        self.baseQuery().findObjectsInBackgroundWithBlock { ( parseObjects, error) -> Void in
            if error == nil {
                print("Found \(parseObjects!.count) orders from server")
                
                self.allLoaded = parseObjects?.count < 10
                
                // First, unpin all existing objects
                PFObject.unpinAllInBackground(self.ordersObjects, block: { (succeeded: Bool, error: NSError?) -> Void in
                    if error == nil {
                        // Pin all the new objects
                        PFObject.pinAllInBackground(parseObjects, block: { (succeeded: Bool, error: NSError?) -> Void in
                            if error == nil {
                                self.shouldUpdateFromParse = false
                                
                                if let objects = parseObjects {
                                    for object in objects {
                                        self.ordersObjects.append(object)
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
        return self.ordersObjects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! OrderTableViewCell

        // Configure the cell...
        
        let order: PFObject = self.ordersObjects[indexPath.row]
        
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
            if !self.allLoaded {
                self.currentPage = Int(self.ordersObjects.count / self.itemPerPage)
                
                self.fetchObjectsFromParse()
            } else {
                // all loaded
                print("all loaded \(self.ordersObjects.count)")
            }
        }
    }
}
