//
//  AddBrandTableViewController.swift
//  GuanJia
//
//  Created by Liang Sun on 12/17/15.
//  Copyright © 2015 Lyon Sun. All rights reserved.
//

import UIKit
import Parse

class AddBrandTableViewController: UITableViewController {

    @IBOutlet weak var brandNameTextField: UITextField!
    
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
    
    // Actions
    
    @IBAction func saveAction(sender: UIBarButtonItem) {
        
        self.saveBrandToParse()
        
        // self.tableView.reloadData()
    }
    
    func saveBrandToParse() {
        let brandName = brandNameTextField.text! as String
        
        if brandName == "" {
            let alert = UIAlertController(title: "Brand Name is required.", message: "Please enter a valid name", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            let query = PFQuery(className: "brand")
            query.whereKey("name", equalTo: brandName)
            query.findObjectsInBackgroundWithBlock({ (categories, error) -> Void in
                if error == nil {
                    // brand already exist
                    if let categories = categories {
                        if categories.count > 0 {
                            let alert = UIAlertController(title: "Brand Name is taken.", message: "Please enter a valid name", preferredStyle: .Alert)
                            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                            
                            self.presentViewController(alert, animated: true, completion: nil)
                        } else {
                            let brand = PFObject(className:"brand")
                            brand["name"] = brandName
                            brand.saveInBackgroundWithBlock {
                                (success, error) -> Void in
                                if (error == nil) {
                                    print("Save brand successful")
                                } else {
                                    print(error)
                                }
                            }
                            
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                    }
                } else {
                    print(error)
                }
            })
        }
        
    }
    
    
    @IBAction func cancelAction(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
