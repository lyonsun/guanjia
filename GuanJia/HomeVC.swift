//
//  HomeVC.swift
//  GuanJia
//
//  Created by Liang Sun on 12/14/15.
//  Copyright © 2015 Lyon Sun. All rights reserved.
//

import UIKit
import Parse

class HomeVC: UIViewController {
    
    // MARK: Properties
    
    var customersCount: Int?
    var ordersCount: Int?
    var productsCount: Int?
    var pendingOrdersCount: Int?
    
    @IBOutlet weak var countLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func loadPendingOrdersCount() {
        productsCount = 0
        
        let query = PFQuery(className:"orders")
        query.whereKey("status", equalTo: 1)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                print("Successfully retrieved \(objects!.count) pending orders")
                
                self.countLabel.text = String(objects!.count)
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        
    }
    
    func loadCount(className: String) {
        productsCount = 0
        
        let query = PFQuery(className: className)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                print("Successfully retrieved \(objects!.count) \(className)")
                
                self.countLabel.text = String(objects!.count)
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        
    }

    @IBAction func segmentTapped(sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 3 {
            loadPendingOrdersCount()
        } else {
            loadCount((sender.titleForSegmentAtIndex(sender.selectedSegmentIndex)?.lowercaseString)!)
        }
    }
}
