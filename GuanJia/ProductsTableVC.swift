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
    
    var products = [PFObject]()
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        loadProductsFromParse()
        
//        let currentUser = PFUser.currentUser()
//        if currentUser != nil {
//            // do somthing here
//            loadProductsFromParse()
//        } else {
//            self.performSegueWithIdentifier("goSignIn", sender: self)
//        }
    }
    
    @IBAction func loadProductsFromParse() {
        products.removeAll()
        
        let query = PFQuery(className:"products")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) products.")
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        // print(object.objectId)
                        self.products.append(object)
                    }
                }
                
                self.title = "Products (\(objects!.count))"
                
                self.tableView.reloadData()
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
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
        return products.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "ProductTableViewCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ProductTableViewCell
        
        cell.nameLabel.alpha = 0
        cell.descLabel.alpha = 0
        cell.stockLabel.alpha = 0
        
        let product = products[indexPath.row]
        
        let name = product["name"] as? String
        let description = product["description"] as? String
        let stock = product["stock"] as? String
        
        cell.nameLabel.text = name
        cell.descLabel.text = description
        
        let IntStock: Int? = Int(stock!)
        if IntStock <= 1 {
            cell.stockLabel.textColor = UIColor.redColor()
        } else if IntStock <= 5 {
            cell.stockLabel.textColor = UIColor.yellowColor()
        } else {
            cell.stockLabel.textColor = UIColor.greenColor()
        }
        
        cell.stockLabel.text = stock
        
        UIView.animateWithDuration(0.5, animations: {
            cell.nameLabel.alpha = 1
            cell.descLabel.alpha = 1
            cell.stockLabel.alpha = 1
        })

        return cell
    }
}
