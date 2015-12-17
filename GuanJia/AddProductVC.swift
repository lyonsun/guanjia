//
//  AddProductVC.swift
//  GuanJia
//
//  Created by Liang Sun on 12/16/15.
//  Copyright © 2015 Lyon Sun. All rights reserved.
//

import UIKit
import Parse

class AddProductVC: UITableViewController, UITextFieldDelegate, UITextViewDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var stockTextField: UITextField!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var brandLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var categorySelected = PFObject(className: "category")
    var brandSelected = PFObject(className: "brand")
    
    // MARK: View rendering

    override func viewDidLoad() {
        super.viewDidLoad()

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
        print(textField)
        checkTextFieldNotEmpty()
    }
    
    @IBAction func saveAction(sender: UIBarButtonItem) {
        print("save tapped")
        
        let name: String? = self.nameTextField.text
        let description: String? = self.descTextView.text
        let stock: Int? = Int(self.stockTextField.text!)
        let pickedImage: UIImage? = self.photoView.image
        
        let image = self.scaleImageWith(pickedImage!, newSize: CGSize(width: 100, height: 100))
        
        let imageData = UIImagePNGRepresentation(image)
        let imageFile = PFFile(name:NSUUID().UUIDString, data:imageData!)
        
        let product = PFObject(className:"product")
        
        product["name"] = name
        product["description"] = description
        product["stock"] = stock
        product["category"] = self.categorySelected
        product["imageFile"] = imageFile
        
        product.saveInBackgroundWithBlock { (success, error) -> Void in
            if error == nil {
                print("Successful store product: \(success)")
            } else {
                print("Error: \(error?.userInfo)")
            }
        }
        
        self.navigationController?.popToRootViewControllerAnimated(true)
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
            let catogoryList = segue.destinationViewController as! CategoryTableViewController
            catogoryList.delegate = self
        } else if segue.identifier == "selectBrand" {
            let brandList = segue.destinationViewController as! BrandTableViewController
            brandList.delegate = self
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
        
        print(categoryName)
        
        self.categorySelected = category as! PFObject
        
        self.categoryLabel.text = categoryName
    }
}

extension AddProductVC: BrandDelegate {
    
    // MARK: Brand Delegate
    
    func userDidSelectBrand(brand: AnyObject) {
        
        let brandName = brand["name"] as? String ?? ""
        
        print(brandName)
        
        self.brandSelected = brand as! PFObject
        
        self.brandLabel.text = brandName
    }
}
