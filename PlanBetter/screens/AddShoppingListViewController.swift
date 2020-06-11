//
//  AddShoppingListViewController.swift
//  PlanBetter
//
//  Created by wflower on 28/11/2019.
//  Copyright © 2019 waterflower. All rights reserved.
//

import UIKit
import Firebase

class AddShoppingListViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var boughtSwitch: UISwitch!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var selected_item = Dictionary<String, Any>()
    let ref = Database.database().reference().child("shopping_list")
    
    ///////   for activity indicator  //////////
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var overlayView:UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        let statusbar_height = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        let background = UIImage(named: "background.png")
        var imageView : UIImageView!
        imageView = UIImageView(frame: CGRect(x: 0, y: statusbar_height, width: view.frame.width, height: view.frame.width * (background?.size.height)! / (background?.size.width)!))
        imageView.contentMode =  UIView.ContentMode.scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = background
//        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
        
        
        self.saveButton.layer.borderWidth = 1
        self.saveButton.layer.borderColor = CGColor.init(srgbRed: 0, green: 0, blue: 0, alpha: 1)
        self.cancelButton.layer.borderWidth = 1
        self.cancelButton.layer.borderColor = CGColor.init(srgbRed: 0, green: 0, blue: 0, alpha: 1)
        
        ////  dismiss keyboard   ///////
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false

        if(self.selected_item.isEmpty) {
            self.boughtSwitch.isOn = false
            self.descriptionTextField.isEnabled = true
            self.cancelButton.setTitle("Cancel", for: .normal)
        } else {
            if(self.selected_item["bought_status"] as! Int == 1) {
                self.boughtSwitch.isOn = true
            } else {
                self.boughtSwitch.isOn = false
            }
            self.nameTextField.text = self.selected_item["goods_name"] as? String
            self.descriptionTextField.text = self.selected_item["goods_note"] as? String
            self.descriptionTextField.isEnabled = false
            self.cancelButton.setTitle("Delete", for: .normal)
            
            
        }
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func saveButtonAction(_ sender: Any) {
        let goods_name = self.nameTextField.text!
        let goods_description = self.descriptionTextField.text!
        if(goods_name == "") {
            self.createAlert(title: "Plan Better", message: "Please input Name.")
            return
        }
//        if(goods_description == "") {
//            self.createAlert(title: "Plan Better", message: "Please input Name.")
//            return
//        }
        
        self.startActivityIndicator()
        let currentDate = Date()
        var bought_status = 0
        if(self.boughtSwitch.isOn) {
            bought_status = 1
        } else {
            bought_status = 0
        }
        if(self.selected_item.isEmpty) {
            let post_data = [
                "goods_name": goods_name,
                "goods_note": goods_description,
                "bought_status": bought_status,
                "createdAt": currentDate.timeIntervalSince1970,
                "party_key": Global.party_key
            ] as [String: Any]
            self.ref.childByAutoId().setValue(post_data, withCompletionBlock:
                {
                    error, ref in
                    if(error != nil) {
                        self.createAlert(title: "Plan Better", message: "Network Error")
                    } else {
                        self.nameTextField.text = ""
                        self.descriptionTextField.text = ""
                        self.boughtSwitch.isOn = false
                        
                    }
                    self.stopActivityIndicator()
                    self.navigationController?.popViewController(animated: true)
            })
        } else {
            let post_data = [
                "goods_name": goods_name,
                "bought_status": bought_status,
            ] as [String: Any]
            let createdAt = self.selected_item["createdAt"] as! NSNumber
            self.ref.queryOrdered(byChild: "createdAt").queryEqual(toValue: createdAt).observeSingleEvent(of:.value, with:  { (snapshot) in
                for child in snapshot.children {
                    if let child = child as? DataSnapshot {
                        self.ref.child(child.key).updateChildValues(post_data)
                    }
                }
                 
                self.stopActivityIndicator()
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        if(self.selected_item.isEmpty) {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.startActivityIndicator()
            let createdAt = self.selected_item["createdAt"] as! NSNumber
            self.ref.queryOrdered(byChild: "createdAt").queryEqual(toValue: createdAt).observeSingleEvent(of:.value, with:  { (snapshot) in
                for child in snapshot.children {
                    if let child = child as? DataSnapshot {
                        self.ref.child(child.key).setValue(nil)
                    }
                }
                self.stopActivityIndicator()
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    func createAlert(title: String, message: String) {
       let alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertController.Style.alert)
       alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
       self.present(alert, animated: true, completion: nil)
    }
    
    func startActivityIndicator() {
        overlayView = UIView(frame:view.frame)
        overlayView.backgroundColor = UIColor.black
        overlayView.alpha = 0.2;
        view.addSubview(overlayView)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.blue
        activityIndicator.style = UIActivityIndicatorView.Style.large
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    func stopActivityIndicator() {
        self.activityIndicator.stopAnimating()
        self.overlayView.removeFromSuperview()
    }
    
}
