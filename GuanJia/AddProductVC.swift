//
//  AddProductVC.swift
//  GuanJia
//
//  Created by Liang Sun on 12/16/15.
//  Copyright © 2015 Lyon Sun. All rights reserved.
//

import UIKit
import Parse

class AddProductVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var stockTextField: UITextField!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        nameTextField.delegate = self
        
        checkTextFieldNotEmpty()
        
        // enable image tap interaction.
        // photoView.userInteractionEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        saveButton.enabled = false
    }
    
    func checkTextFieldNotEmpty() {
        let nameText = nameTextField.text ?? ""
        let descText = descTextView.text ?? ""
        let stockText = stockTextField.text ?? ""
        
        print("\(nameText)")
        saveButton.enabled = !nameText.isEmpty && !descText.isEmpty && !stockText.isEmpty
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        checkTextFieldNotEmpty()
    }
    
    @IBAction func selectImageTapped(sender: UITapGestureRecognizer) {
        print("select image tapped")
        nameTextField.resignFirstResponder()
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.sourceType = .PhotoLibrary
        imagePickerController.delegate = self
        
        self.presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func saveAction(sender: UIBarButtonItem) {
        print("save tapped")
        
        let name: String? = self.nameTextField.text
        let description: String? = self.descTextView.text
        let stock: Int? = Int(self.stockTextField.text!)
        let pickedImage: UIImage? = self.photoView.image
        
        let image = self.scaleImageWith(pickedImage!, newSize: CGSize(width: 100, height: 100))
        
        let imageData = UIImagePNGRepresentation(image)
        let imageFile = PFFile(name:name, data:imageData!)
        
        let product = PFObject(className:"product")
        
        product["name"] = name
        product["description"] = description
        product["stock"] = stock
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
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        photoView.image = selectedImage
        dismissViewControllerAnimated(true, completion: nil)
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
