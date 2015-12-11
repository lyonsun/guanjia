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

class ProductTableViewController: UITableViewController {
    
    var sample_products = [Product]?()
    
    var products: Array<Product>?
    var productsWrapper:ProductsWrapper? // holds the last wrapper that we've loaded
    var isLoadingProducts = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
//        loadSampleProducts()
        
        loadProducts()
    }
    
    func loadSampleProducts() {
        
        let json_product1 = JSON(rawValue: ["name": "Product1", "description": "This is product 1"])!
        let json_product2 = JSON(rawValue: ["name": "Product2", "description": "This is product 2"])!
        
        let product1 = Product(json: json_product1)
        let product2 = Product(json: json_product2)
        
        sample_products = [product1, product2]
    }
    
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

    // MARK: - Table view data source

    /*
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    */

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if self.products == nil {
            return 0
        }
        
        return products!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "ProductTableViewCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ProductTableViewCell
        
        let product = products![indexPath.row]
        
        cell.nameLabel.text = product.name
        cell.descLabel.text = product.description

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
