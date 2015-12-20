//
//  BrandTableViewController.swift
//  GuanJia
//
//  Created by Liang Sun on 12/17/15.
//  Copyright © 2015 Lyon Sun. All rights reserved.
//

import UIKit
import Parse

protocol BrandDelegate: class {
    func userDidSelectBrand(brand: AnyObject)
}

class BrandTableViewController: UITableViewController {
    
    weak var delegate: BrandDelegate? = nil
    
    var brandsObjects = [PFObject]()
    
    var brand: String?

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchBrandsFromParse()
    }
    
    func fetchBrandsFromParse() {
        brandsObjects.removeAll()
        
        let query = PFQuery(className: "brand")
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                print("Successfully retrieved \(objects!.count) brands.")
                if let brands = objects {
                    for brand in brands {
                        self.brandsObjects.append(brand)
                    }
                }
                
                self.tableView.reloadData()
            } else {
                print(error)
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
        return brandsObjects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)

        // Configure the cell...
        
        let brand = self.brandsObjects[indexPath.row]
        
        let brandName = brand["name"] as? String
        
        cell.textLabel?.text = brandName
        
        if self.brand != nil && self.brand == brandName {
            cell.accessoryType = .Checkmark
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let brand = self.brandsObjects[indexPath.row]
        
        // call this method on whichever class implements our delegate protocol
        delegate?.userDidSelectBrand(brand)
        
        // go back to the previous view controller
        self.navigationController?.popViewControllerAnimated(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
