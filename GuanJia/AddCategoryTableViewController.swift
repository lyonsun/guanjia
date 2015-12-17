//
//  AddCategoryTableViewController.swift
//  GuanJia
//
//  Created by Liang Sun on 12/17/15.
//  Copyright © 2015 Lyon Sun. All rights reserved.
//

import UIKit
import Parse

class AddCategoryTableViewController: UITableViewController {

    @IBOutlet weak var categoryNameTextField: UITextField!
    
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
    
    @IBAction func saveAction(sender: UIBarButtonItem) {
        saveCategoryToParse()
        
        self.tableView.reloadData()
    }
    
    func saveCategoryToParse() {
        
        let categoryName = categoryNameTextField.text! as String
        
        if categoryName == "" {
            let alert = UIAlertController(title: "Category Name is required.", message: "Please enter a valid name", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            let query = PFQuery(className: "category")
            query.whereKey("name", equalTo: categoryName)
            query.findObjectsInBackgroundWithBlock({ (categories, error) -> Void in
                if error == nil {
                    // category already exist
                    if let categories = categories {
                        if categories.count > 0 {
                            let alert = UIAlertController(title: "Category Name is taken.", message: "Please enter a valid name", preferredStyle: .Alert)
                            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                            
                            self.presentViewController(alert, animated: true, completion: nil)
                        } else {
                            let category = PFObject(className:"category")
                            category["name"] = categoryName
                            category.saveInBackgroundWithBlock {
                                (success, error) -> Void in
                                if (error == nil) {
                                    print("Save category successful")
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
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
}
