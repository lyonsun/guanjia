//
//  CategoryTableViewController.swift
//  GuanJia
//
//  Created by Liang Sun on 12/17/15.
//  Copyright © 2015 Lyon Sun. All rights reserved.
//

import UIKit
import Parse

protocol CategoryDelegate: class {
    func userDidSelectCategory(category: AnyObject)
}

class CategoryTableViewController: UITableViewController {
    
    weak var delegate: CategoryDelegate? = nil
    
    var categories = [PFObject]()

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchCategories()
    }
    
    func fetchCategories() {
        categories.removeAll()
        
        let query = PFQuery(className:"category")
        query.findObjectsInBackgroundWithBlock {
            (objects, error) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) categories.")
                // Do something with the found objects
                
                if let objects = objects {
                    for object in objects {
                        self.categories.append(object)
                    }
                }
                
                self.tableView.reloadData()
            } else {
                // Log details of the failure
                print(error?.userInfo)
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
        return self.categories.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...
        let category = self.categories[indexPath.row]
        
        cell.textLabel?.text = category["name"] as? String

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let category = self.categories[indexPath.row]
        
        // call this method on whichever class implements our delegate protocol
        delegate?.userDidSelectCategory(category)
        
        // go back to the previous view controller
        self.navigationController?.popViewControllerAnimated(true)
        
        
    }
}