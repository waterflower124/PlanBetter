//
//  AddExpensesViewController.swift
//  PlanBetter
//
//  Created by wflower on 18/11/2019.
//  Copyright © 2019 waterflower. All rights reserved.
//

import UIKit
import Firebase

class AddExpensesViewController: UIViewController {

    @IBOutlet weak var paidView: UIView!
    @IBOutlet weak var paidYesButton: UIButton!
    @IBOutlet weak var paidNoButton: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var expensenameTextField: UITextField!
    @IBOutlet weak var expensecostTextField: UITextField!
    @IBOutlet weak var expensenoteTextField: UITextField!
    
    ///////   for activity indicator  //////////
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var overlayView:UIView = UIView()
    
    let ref = Database.database().reference().child("expenses_list")
    var selected_expense = Dictionary<String, Any>()
    
    var paid = 1
    
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
        
        self.paidView.layer.borderWidth = 1
        self.paidView.layer.borderColor = CGColor.init(srgbRed: 0, green: 0, blue: 0, alpha: 1)
        self.paidView.layer.cornerRadius = 5
        
        self.paidYesButton.backgroundColor = UIColor.gray
        self.paidYesButton.setTitleColor(.white, for: .normal)
        self.paidNoButton.backgroundColor = UIColor.white
        self.paidNoButton.setTitleColor(.black, for: .normal)
        
        self.saveButton.layer.borderWidth = 1
        self.saveButton.layer.borderColor = CGColor.init(srgbRed: 0, green: 0, blue: 0, alpha: 1)
        self.cancelButton.layer.borderWidth = 1
        self.cancelButton.layer.borderColor = CGColor.init(srgbRed: 0, green: 0, blue: 0, alpha: 1)
        
        ////  dismiss keyboard   ///////
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        
        if(self.selected_expense.isEmpty) {
            self.cancelButton.setTitle("Cancel", for: .normal)
        } else {
            self.cancelButton.setTitle("Delete", for: .normal)
            self.expensenameTextField.text = self.selected_expense["expense_name"] as? String
            self.expensecostTextField.text = String(self.selected_expense["expense_cost"] as! Int)
            self.expensenoteTextField.text = self.selected_expense["expense_note"] as? String
            if(self.selected_expense["paid"] as! Int == 1) {
                self.paid = 1
                self.paidYesButton.backgroundColor = UIColor.gray
                self.paidYesButton.setTitleColor(.white, for: .normal)
                self.paidNoButton.backgroundColor = UIColor.white
                self.paidNoButton.setTitleColor(.black, for: .normal)
            } else {
                self.paid = 0
                self.paidYesButton.backgroundColor = UIColor.white
                self.paidYesButton.setTitleColor(.black, for: .normal)
                self.paidNoButton.backgroundColor = UIColor.gray
                self.paidNoButton.setTitleColor(.white, for: .normal)
            }
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func paidYesButtonAction(_ sender: Any) {
        self.paid = 1
        self.paidYesButton.backgroundColor = UIColor.gray
        self.paidYesButton.setTitleColor(.white, for: .normal)
        self.paidNoButton.backgroundColor = UIColor.white
        self.paidNoButton.setTitleColor(.black, for: .normal)
    }
    
    @IBAction func paidNoButtonAction(_ sender: Any) {
        self.paid = 0
        self.paidYesButton.backgroundColor = UIColor.white
        self.paidYesButton.setTitleColor(.black, for: .normal)
        self.paidNoButton.backgroundColor = UIColor.gray
        self.paidNoButton.setTitleColor(.white, for: .normal)
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
        let expense_name = self.expensenameTextField.text!
        let expense_cost = self.expensecostTextField.text!
        let expense_note = self.expensenoteTextField.text!
        if(expense_name == "") {
            self.createAlert(title: "Plan Better", message: "Please input Name.")
            return
        }
        if(expense_cost == "") {
            self.createAlert(title: "Plan Better", message: "Please input Cost.")
            return
        }
//        if(expense_note == "") {
//            self.createAlert(title: "Plan Better", message: "Please input Note.")
//            return
//        }
        
        self.startActivityIndicator()
        let currentDate = Date()
        
        if(self.selected_expense.isEmpty) {
            let post_data = [
                "expense_name": expense_name,
                "expense_cost": Int(expense_cost)!,
                "expense_note": expense_note,
                "paid": self.paid,
                "createdAt": currentDate.timeIntervalSince1970,
                "party_key": Global.party_key
            ] as [String: Any]
            self.ref.childByAutoId().setValue(post_data, withCompletionBlock:
                {
                    error, ref in
                    if(error != nil) {
                        self.createAlert(title: "Plan Better", message: "Network Error")
                    } else {
                        self.expensenameTextField.text = ""
                        self.expensecostTextField.text = ""
                        self.expensenoteTextField.text = ""
                        
                        self.paid = 1
                        self.paidYesButton.backgroundColor = UIColor.gray
                        self.paidYesButton.setTitleColor(.white, for: .normal)
                        self.paidNoButton.backgroundColor = UIColor.white
                        self.paidNoButton.setTitleColor(.black, for: .normal)
                        
                    }
                    self.stopActivityIndicator()
                    self.navigationController?.popViewController(animated: true)
            })
        } else {
            let post_data = [
                "expense_name": expense_name,
                "expense_cost": Int(expense_cost)!,
                "expense_note": expense_note,
                "paid": self.paid,
            ] as [String: Any]
            let createdAt = self.selected_expense["createdAt"] as! NSNumber
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
        if(self.selected_expense.isEmpty) {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.startActivityIndicator()
            let createdAt = self.selected_expense["createdAt"] as! NSNumber
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
