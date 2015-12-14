//
//  ProductTableViewController.swift
//  GuanJia
//
//  Created by Liang Sun on 12/11/15.
//  Copyright © 2015 Lyon Sun. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Parse

class ProductTableVC: UITableViewController {
    
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
                
                self.tableView.reloadData()
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    
    
    
/*    ++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    
    var sample_products = [Product]?()
    
    var products: [PFObject]?
    var productsWrapper:ProductsWrapper? // holds the last wrapper that we've loaded
    var isLoadingProducts = false

//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Uncomment the following line to preserve selection between presentations
//        // self.clearsSelectionOnViewWillAppear = false
//
//        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
//        
//        // loadSampleProducts()
//        
//        loadProducts()
//    }
    
    /*
    func loadSampleProducts() {
        
        let json_product1 = JSON(rawValue: ["name": "Product1", "description": "This is product 1"])!
        let json_product2 = JSON(rawValue: ["name": "Product2", "description": "This is product 2"])!
        
        let product1 = Product(json: json_product1)
        let product2 = Product(json: json_product2)
        
        sample_products = [product1, product2]
    }
    */
    
    func loadProducts() {
        isLoadingProducts = true
        Product.getProducts({ (productsWrapper, error) in
            if error != nil
            {
                // TODO: improved error handling
                self.isLoadingProducts = false
                let alert = UIAlertController(title: "Error", message: "Could not load products \(error?.localizedDescription)", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            print(productsWrapper);
            self.addProductsFromWrapper(productsWrapper)
            self.isLoadingProducts = false
            self.tableView?.reloadData()
        })
    }
    
    func addProductsFromWrapper(wrapper: ProductsWrapper?)
    {
        self.productsWrapper = wrapper
        if self.products == nil
        {
            self.products = self.productsWrapper?.products
        }
        else if self.productsWrapper != nil && self.productsWrapper!.products != nil
        {
            self.products = self.products! + self.productsWrapper!.products!
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

*/

    // MARK: - Table view data source

    /*
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    */

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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
