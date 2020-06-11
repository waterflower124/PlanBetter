//
//  EditToDoViewController.swift
//  PlanBetter
//
//  Created by wflower on 26/11/2019.
//  Copyright © 2019 waterflower. All rights reserved.
//

import UIKit
import Firebase

class EditToDoViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var todoSwitch: UISwitch!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    let ref = Database.database().reference().child("to-do_list")
    var selected_todo = Dictionary<String, Any>()
    
    ///////   for activity indicator  //////////
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var overlayView:UIView = UIView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.nameTextField.text = self.selected_todo["todo_name"] as? String
        self.descriptionTextField.text = self.selected_todo["todo_description"] as? String
        if(self.selected_todo["open"] as? Int == 1) {
            self.todoSwitch.isOn = false
        } else {
            self.todoSwitch.isOn = true
        }
        
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        let statusbar_height = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        let background = UIImage(named: "background.png")
        var imageView : UIImageView!
        imageView = UIImageView(frame: CGRect(x: 0, y: statusbar_height + (navigationController?.navigationBar.frame.height)!, width: view.frame.width, height: view.frame.width * (background?.size.height)! / (background?.size.width)!))
        imageView.contentMode =  UIView.ContentMode.scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = background
//        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
        
        self.saveButton.layer.borderWidth = 1
        self.saveButton.layer.borderColor = CGColor.init(srgbRed: 0, green: 0, blue: 0, alpha: 1)
        self.deleteButton.layer.borderWidth = 1
        self.deleteButton.layer.borderColor = CGColor.init(srgbRed: 0, green: 0, blue: 0, alpha: 1)
        
        ////  dismiss keyboard   ///////
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func todoSwitchAction(_ sender: Any) {
        self.startActivityIndicator()
       
        let createdAt = self.selected_todo["createdAt"] as! NSNumber
        self.ref.queryOrdered(byChild: "createdAt").queryEqual(toValue: createdAt).observeSingleEvent(of:.value, with:  { (snapshot) in
            for child in snapshot.children {
                if let child = child as? DataSnapshot {
                    if(self.todoSwitch.isOn) {
                        self.ref.child(child.key).child("open").setValue(0)
                    } else {
                        self.ref.child(child.key).child("open").setValue(1)
                    }
                    
                }
            }
            
            self.stopActivityIndicator()
        })
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
        let todo_name = self.nameTextField.text!
        let todo_description = self.descriptionTextField.text!
        if(todo_name == "") {
            self.createAlert(title: "Plan Better", message: "Please input name.")
            return
        }
//        if(todo_description == "") {
//            self.createAlert(title: "Plan Better", message: "Please input description.")
//            return
//        }
        
        self.startActivityIndicator()
        
        let createdAt = self.selected_todo["createdAt"] as! NSNumber
        self.ref.queryOrdered(byChild: "createdAt").queryEqual(toValue: createdAt).observeSingleEvent(of:.value, with:  { (snapshot) in
            for child in snapshot.children {
                if let child = child as? DataSnapshot {
                    self.ref.child(child.key).updateChildValues(["todo_name": todo_name, "todo_description": todo_description])
                    self.nameTextField.text = ""
                    self.descriptionTextField.text = ""
                }
            }
             
            self.stopActivityIndicator()
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    @IBAction func deleteButtonAction(_ sender: Any) {
        self.startActivityIndicator()
        
        let createdAt = self.selected_todo["createdAt"] as! NSNumber
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
