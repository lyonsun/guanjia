//
//  ProductTableViewController.swift
//  GuanJia
//
//  Created by Liang Sun on 12/11/15.
//  Copyright © 2015 Lyon Sun. All rights reserved.
//

import UIKit
import Parse

class ProductsTableVC: UITableViewController {
    
    // MARK: Properties
    
    var productsObjects = [PFObject]()
    
    var shouldUpdateFromParse: Bool = true
    var allLoaded: Bool = false
    
    var currentPage: Int = 0
    let itemPerPage: Int = 10
    
    // MARK: View Rendering
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.shouldUpdateFromParse {
            if !self.allLoaded {
                self.fetchObjectsFromParse()
            }
        } else {
            shouldUpdateFromParse = true
        }
    }
    
    // MARK: Parse Querying
    
    func baseQuery() -> PFQuery {
        let query = PFQuery(className: "product")
        
        query.limit = itemPerPage
        query.skip = currentPage * itemPerPage
        query.orderByDescending("updatedAt")
        
        return query
    }
    
    func fetchObjectsFromParse() {
        self.baseQuery().fromLocalDatastore()
        self.baseQuery().findObjectsInBackgroundWithBlock { ( parseObjects, error) -> Void in
            if error == nil {
                print("Found \(parseObjects!.count) products from server")
                
                self.allLoaded = parseObjects?.count < 10
                
                // First, unpin all existing objects
                PFObject.unpinAllInBackground(self.productsObjects, block: { (succeeded: Bool, error: NSError?) -> Void in
                    if error == nil {
                        // Pin all the new objects
                        PFObject.pinAllInBackground(parseObjects, block: { (succeeded: Bool, error: NSError?) -> Void in
                            if error == nil {
                                self.shouldUpdateFromParse = false
                                
                                if let objects = parseObjects {
                                    for object in objects {
                                        self.productsObjects.append(object)
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
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productsObjects.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ProductTableViewCell", forIndexPath: indexPath) as! ProductTableViewCell
        
        let product = productsObjects[indexPath.row]
        let name = product["name"] as! String
        let description = product["description"] as! String
        let stock = product["stock"] as! Int
        let thumbmail = product["imageFile"] as! PFFile
        
        if stock <= 5 {
            cell.stockLabel.textColor = UIColor.redColor()
        } else {
            cell.stockLabel.textColor = UIColor.greenColor()
        }

        cell.nameLabel.text = name
        cell.descLabel.text = description
        cell.stockLabel.text = String(stock)
        
        thumbmail.getDataInBackgroundWithBlock { (imageData, error) -> Void in
            if error == nil {
                let image = UIImage(data: imageData!)
                cell.photoView.image = image
            }
        }
        
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
                self.currentPage = Int(self.productsObjects.count / self.itemPerPage)
                
                self.fetchObjectsFromParse()
            } else {
                // all loaded
                print("all loaded \(self.productsObjects.count)")
            }
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editProduct" {
            print("edit button pressed")
        }
        else if segue.identifier == "addProduct" {
            print("add button pressed")
        }
    }
}
