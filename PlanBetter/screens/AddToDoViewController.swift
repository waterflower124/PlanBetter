//
//  AddToDoViewController.swift
//  PlanBetter
//
//  Created by wflower on 17/11/2019.
//  Copyright © 2019 waterflower. All rights reserved.
//

import UIKit
import Firebase

class AddToDoViewController: UIViewController {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var taskNameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
    ///////   for activity indicator  //////////
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var overlayView:UIView = UIView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        self.cancelButton.layer.borderWidth = 1
        self.cancelButton.layer.borderColor = CGColor.init(srgbRed: 0, green: 0, blue: 0, alpha: 1)
        
        ////  dismiss keyboard   ///////
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func cancelButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
        let task_name = self.taskNameTextField.text!
        let task_description = self.descriptionTextField.text!
        if(task_name == "") {
            self.createAlert(title: "Plan Better", message: "Please input Party Name.")
            return
        }
//        if(task_description == "") {
//            self.createAlert(title: "Plan Better", message: "Please input Party Type.")
//            return
//        }
        
        let todoDate = self.datePicker.date
        let currentDate = Date()
        
        self.startActivityIndicator()
        let post_data = [
            "todo_name": task_name,
            "todo_description": task_description,
            "todo_datetime": todoDate.timeIntervalSince1970,
            "createdAt": currentDate.timeIntervalSince1970,
            "party_key": Global.party_key,
            "open": 1
        ] as [String: Any]
        let ref = Database.database().reference().child("to-do_list")
        ref.childByAutoId().setValue(post_data, withCompletionBlock:
            {
                error, ref in
                if(error != nil) {
                    self.createAlert(title: "Plan Better", message: "Network Error")
                } else {
                    
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
//        UIApplication.shared.beginIgnoringInteractionEvents();
    }
    
    func stopActivityIndicator() {
        self.activityIndicator.stopAnimating()
        self.overlayView.removeFromSuperview()
//        if UIApplication.shared.isIgnoringInteractionEvents {
//            UIApplication.shared.endIgnoringInteractionEvents();
//        }
    }
}
