//
//  AddProductVC.swift
//  GuanJia
//
//  Created by Liang Sun on 12/16/15.
//  Copyright © 2015 Lyon Sun. All rights reserved.
//

import UIKit
import Parse

protocol ProductDelegate: class {
    func userDidSaveProduct(message: String)
}

class AddProductVC: UITableViewController, UITextFieldDelegate, UITextViewDelegate {
    
    // MARK: Properties
    
    weak var delegate: ProductDelegate? = nil
    
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var stockTextField: UITextField!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var brandLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var product: PFObject?
    
    var mode: String? = ""
    
    var categorySelected: PFObject?
    var brandSelected: PFObject?
    
    // MARK: View rendering

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.product != nil {
            
            self.mode = "edit"
            
            let thumbmail = self.product!["imageFile"] as! PFFile
            
            thumbmail.getDataInBackgroundWithBlock { (imageData, error) -> Void in
                if error == nil {
                    let image = UIImage(data: imageData!)
                    self.photoView?.image = image
                }
            }
            
            var categoryName: String?
            
            if self.product!["category"] != nil {
                let category = self.product!["category"] as! PFObject
                
                category.fetchIfNeededInBackgroundWithBlock({ (fetchedCategory, error) -> Void in
                    if fetchedCategory!["name"] != nil {
                        categoryName = fetchedCategory!["name"] as? String
                    } else {
                        categoryName = "Category Not Found"
                    }
                })
                
                self.categorySelected = category
            } else {
                categoryName = "Select a Category"
            }
            
            var brandName: String?
            
            if self.product!["brand"] != nil {
                let brand = self.product!["brand"] as! PFObject
                
                brand.fetchIfNeededInBackgroundWithBlock({ (fetchedBrand, error) -> Void in
                    if fetchedBrand!["name"] != nil {
                        brandName = fetchedBrand!["name"] as? String
                    } else {
                        brandName = "Brand Not Found"
                    }
                })
                
                self.brandSelected = brand
            } else {
                brandName = "Select a Brand"
            }
            
            self.categoryLabel?.text = categoryName
            self.brandLabel?.text = brandName
            
            let stock = self.product!["stock"] as! Int
            
            self.nameTextField?.text = self.product!["name"] as? String
            self.descTextView?.text = self.product!["description"] as! String
            self.stockTextField?.text = String(stock)
        } else {
            self.product = PFObject(className: "product")
            self.categorySelected = PFObject(className: "category")
            self.categorySelected!["name"] = "Uncategoried"
            self.brandSelected = PFObject(className: "brand")
            self.brandSelected!["name"] = "Unbranded"
        }

        // Do any additional setup after loading the view.
        nameTextField.delegate = self
        stockTextField.delegate = self
        descTextView.delegate = self
        
        checkTextFieldNotEmpty()
        
        self.tableView.keyboardDismissMode = .Interactive
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Validation & Actions
    
    func textFieldDidBeginEditing(textField: UITextField) {
        saveButton.enabled = false
    }
    
    func checkTextFieldNotEmpty() {
        let nameText = nameTextField.text ?? ""
        let stockText = stockTextField.text ?? ""
        
        saveButton.enabled = !nameText.isEmpty && !stockText.isEmpty
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        checkTextFieldNotEmpty()
    }
    
    @IBAction func saveAction(sender: UIBarButtonItem) {
        let name: String? = self.nameTextField.text
        let description: String? = self.descTextView.text
        let stock: Int? = Int(self.stockTextField.text!)
        let pickedImage: UIImage? = self.photoView.image
        
        let image = self.scaleImageWith(pickedImage!, newSize: CGSize(width: 100, height: 100))
        
        let imageData = UIImagePNGRepresentation(image)
        let imageFile = PFFile(name:NSUUID().UUIDString, data:imageData!)
        
        self.product!["name"] = name
        self.product!["description"] = description
        self.product!["stock"] = stock
            
        self.product!["category"] = self.categorySelected
        self.product!["brand"] = self.brandSelected
        self.product!["imageFile"] = imageFile
        
        let alert = UIAlertController(title: "Saving...", message: "", preferredStyle: .Alert)
        
        self.presentViewController(alert, animated: true, completion: nil)
        
        self.product!.saveInBackgroundWithBlock { (success, error) -> Void in
            if error == nil {
                print("Successful store product: \(success)")
                
                self.dismissViewControllerAnimated(true, completion: nil)
                
                self.delegate?.userDidSaveProduct(self.mode!)
                
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                print("Error: \(error?.userInfo)")
            }
        }
    }
    
    func scaleImageWith(image: UIImage, newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    // MARK: Table View Delegate
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == 0 || (indexPath.section == 1 && (indexPath.row == 2 || indexPath.row == 3)) {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            let imagePickerController = UIImagePickerController()
            
            imagePickerController.sourceType = .PhotoLibrary
            imagePickerController.delegate = self
            
            self.presentViewController(imagePickerController, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "selectCategory" {
            let categoryList = segue.destinationViewController as! CategoryTableViewController
            categoryList.delegate = self
            categoryList.category = self.categoryLabel?.text
        } else if segue.identifier == "selectBrand" {
            let brandList = segue.destinationViewController as! BrandTableViewController
            brandList.delegate = self
            brandList.brand = self.brandLabel?.text
        }
    }
}

extension AddProductVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: Image Picker Delegate
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        photoView.image = selectedImage
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension AddProductVC: CategoryDelegate {
    
    // MARK: Category Delegate
    
    func userDidSelectCategory(category: AnyObject) {
        
        let categoryName = category["name"] as? String ?? ""
        
        self.categorySelected = category as? PFObject
        
        self.categoryLabel.text = categoryName
    }
}

extension AddProductVC: BrandDelegate {
    
    // MARK: Brand Delegate
    
    func userDidSelectBrand(brand: AnyObject) {
        
        let brandName = brand["name"] as? String ?? ""
        
        self.brandSelected = brand as? PFObject
        
        self.brandLabel.text = brandName
    }
}
