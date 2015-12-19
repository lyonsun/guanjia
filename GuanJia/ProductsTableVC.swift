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
    
    var refreshController: UIRefreshControl =  UIRefreshControl()
    
    // MARK: View Rendering
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentPage = 0
        let removeAll: Bool = true
        self.fetchObjectsFromParse(removeAll)
        
        navigationItem.leftBarButtonItem = editButtonItem()
        
        // self.refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh")
        
        refreshController.backgroundColor = UIColor.grayColor()

        self.refreshController.addTarget(self, action: "refreshTable:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshController)
    }
    
    func refreshTable(sender:AnyObject) {
        print("refreshing....")
        
        currentPage = 0
        let removeAll: Bool = true
        self.fetchObjectsFromParse(removeAll)
    }
    
//    override func viewWillAppear(animated: Bool) {
//        currentPage = 0
//        let removeAll: Bool = true
//        self.fetchObjectsFromParse(removeAll)
//    }
    
    // MARK: Parse Querying
    
    func baseQuery() -> PFQuery {
        let query = PFQuery(className: "product")
        query.includeKey("category")
        query.includeKey("brand")
        
        query.limit = itemPerPage
        query.skip = currentPage * itemPerPage
        query.orderByDescending("updatedAt")
        
        return query
    }
    
    func fetchObjectsFromParse(removeAll: Bool) {
        self.baseQuery().fromLocalDatastore()
        self.baseQuery().findObjectsInBackgroundWithBlock { ( parseObjects, error) -> Void in
            if error == nil {
                
                if removeAll {
                    self.productsObjects.removeAll(keepCapacity: false)
                    // reload table for safty from array out of range.
                    self.tableView.reloadData()
                }
                
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
                                
                                // end refreshing after loaded
                                self.refreshController.endRefreshing()
                                
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
        
        var categoryName: String?
        
        if product["category"] != nil {
            let category = product["category"] as! PFObject
            
            category.fetchIfNeededInBackgroundWithBlock({ (fetchedCategory, error) -> Void in
                if fetchedCategory!["name"] != nil {
                    categoryName = fetchedCategory!["name"] as? String
                } else {
                    categoryName = "Category Not Found"
                }
            })
        } else {
            categoryName = "No Category"
        }
        
        var brandName: String?
        
        if product["brand"] != nil {
            let brand = product["brand"] as! PFObject
            
            brand.fetchIfNeededInBackgroundWithBlock({ (fetchedBrand, error) -> Void in
                if fetchedBrand!["name"] != nil {
                    brandName = fetchedBrand!["name"] as? String
                } else {
                    brandName = "Brand Not Found"
                }
            })
        } else {
            brandName = "No Brand"
        }
        
        let stock = product["stock"] as! Int
        let thumbmail = product["imageFile"] as! PFFile
        
        if stock <= 5 {
            cell.stockLabel.textColor = UIColor.redColor()
        } else {
            cell.stockLabel.textColor = UIColor.greenColor()
        }

        cell.nameLabel.text = name
        cell.categoryLabel.text = categoryName
        cell.brandLabel.text = brandName
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
                
                self.fetchObjectsFromParse(false)
            } else {
                // all loaded
                print("all loaded \(self.productsObjects.count)")
            }
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            
            for path in [indexPath] {
                let product = productsObjects[path.row]
                let objectId:String = product.objectId!
                
                let query = PFQuery(className: "product")
                
                query.whereKey("objectId", equalTo: objectId)
                query.findObjectsInBackgroundWithBlock {
                    (objects, error) -> Void in
                    if error == nil {
                        if let products = objects {
                            for product in products {
                                product.deleteInBackgroundWithBlock({ (success, error) -> Void in
                                    if error != nil {
                                        print(error)
                                    }
                                })
                            }
                        }
                    } else {
                        print(error)
                    }
                }
                productsObjects.removeAtIndex(path.row)
            }
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let dest: AddProductVC = segue.destinationViewController as! AddProductVC
        
        if segue.identifier == "editProduct" {
            print("edit mode")
            let indexPath: NSIndexPath = self.tableView.indexPathForSelectedRow!
            
            let product = self.productsObjects[indexPath.row]
            
            dest.product = product
            
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        else if segue.identifier == "addProduct" {
            print("add mode")
        }
        
        dest.delegate = self
    }
}

extension ProductsTableVC: ProductDelegate {
    func userDidSaveProduct(message: String) {
        currentPage = 0
        let removeAll: Bool = true
        self.fetchObjectsFromParse(removeAll)
    }
}
