//
//  AddGuestViewController.swift
//  PlanBetter
//
//  Created by wflower on 18/11/2019.
//  Copyright © 2019 waterflower. All rights reserved.
//

import UIKit
import Firebase

class AddGuestViewController: UIViewController {

    @IBOutlet weak var guestNameTextField: UITextField!
    @IBOutlet weak var numberTextField: UITextField!
    
    @IBOutlet weak var inviteView: UIView!
    @IBOutlet weak var inviteYesButton: UIButton!
    @IBOutlet weak var inviteNoButton: UIButton!
    
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusOpenButton: UIButton!
    @IBOutlet weak var statusConfirmButton: UIButton!
    @IBOutlet weak var statusCancelButton: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    ///////   for activity indicator  //////////
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var overlayView:UIView = UIView()
    
    var invited = 1
    var status = "open"
    
    let ref = Database.database().reference().child("guest_list")
    
    var selected_guest = Dictionary<String, Any>()
    
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
        
        self.inviteView.layer.borderWidth = 1
        self.inviteView.layer.borderColor = CGColor.init(srgbRed: 0, green: 0, blue: 0, alpha: 1)
        self.inviteView.layer.cornerRadius = 5
        
        self.inviteYesButton.backgroundColor = UIColor.gray
        self.inviteYesButton.setTitleColor(.white, for: .normal)
        
        self.statusView.layer.borderWidth = 1
        self.statusView.layer.borderColor = CGColor.init(srgbRed: 0, green: 0, blue: 0, alpha: 1)
        self.statusView.layer.cornerRadius = 5
        
        self.statusOpenButton.backgroundColor = UIColor.gray
        self.statusOpenButton.setTitleColor(.white, for: .normal)
        self.statusConfirmButton.backgroundColor = UIColor.white
        self.statusConfirmButton.setTitleColor(.black, for: .normal)
        self.statusCancelButton.backgroundColor = UIColor.white
        self.statusCancelButton.setTitleColor(.black, for: .normal)
        
        self.saveButton.layer.borderWidth = 1
        self.saveButton.layer.borderColor = CGColor.init(srgbRed: 0, green: 0, blue: 0, alpha: 1)
        self.cancelButton.layer.borderWidth = 1
        self.cancelButton.layer.borderColor = CGColor.init(srgbRed: 0, green: 0, blue: 0, alpha: 1)
        
        if(!self.selected_guest.isEmpty) {
            self.cancelButton.setTitle("Delete", for: .normal)
            self.guestNameTextField.text = self.selected_guest["guest_name"] as? String
            self.numberTextField.text = String(self.selected_guest["person_number"] as! Int)
            if(self.selected_guest["invited"] as! Int == 1) {
                self.invited = 1
                self.inviteYesButton.backgroundColor = UIColor.gray
                self.inviteYesButton.setTitleColor(.white, for: .normal)
                self.inviteNoButton.backgroundColor = UIColor.white
                self.inviteNoButton.setTitleColor(.black, for: .normal)
            } else {
                self.invited = 0
                self.inviteYesButton.backgroundColor = UIColor.white
                self.inviteYesButton.setTitleColor(.black, for: .normal)
                self.inviteNoButton.backgroundColor = UIColor.gray
                self.inviteNoButton.setTitleColor(.white, for: .normal)
            }
            
            if(self.selected_guest["status"] as? String == "open") {
                self.status = "open"
                self.statusOpenButton.backgroundColor = UIColor.gray
                self.statusOpenButton.setTitleColor(.white, for: .normal)
                self.statusConfirmButton.backgroundColor = UIColor.white
                self.statusConfirmButton.setTitleColor(.black, for: .normal)
                self.statusCancelButton.backgroundColor = UIColor.white
                self.statusCancelButton.setTitleColor(.black, for: .normal)
            } else if(self.selected_guest["status"] as? String == "confirm") {
                self.status = "confirm"
                self.statusOpenButton.backgroundColor = UIColor.white
                self.statusOpenButton.setTitleColor(.black, for: .normal)
                self.statusConfirmButton.backgroundColor = UIColor.gray
                self.statusConfirmButton.setTitleColor(.white, for: .normal)
                self.statusCancelButton.backgroundColor = UIColor.white
                self.statusCancelButton.setTitleColor(.black, for: .normal)
            } else {
                self.status = "cancel"
                self.statusOpenButton.backgroundColor = UIColor.white
                self.statusOpenButton.setTitleColor(.black, for: .normal)
                self.statusConfirmButton.backgroundColor = UIColor.white
                self.statusConfirmButton.setTitleColor(.black, for: .normal)
                self.statusCancelButton.backgroundColor = UIColor.gray
                self.statusCancelButton.setTitleColor(.white, for: .normal)
            }
        } else {
            self.cancelButton.setTitle("Cancel", for: .normal)
        }
        
        ////  dismiss keyboard   ///////
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func inviteYesButtonAction(_ sender: Any) {
        self.invited = 1
        self.inviteYesButton.backgroundColor = UIColor.gray
        self.inviteYesButton.setTitleColor(.white, for: .normal)
        self.inviteNoButton.backgroundColor = UIColor.white
        self.inviteNoButton.setTitleColor(.black, for: .normal)
    }
    
    @IBAction func inviteNoButton(_ sender: Any) {
        self.invited = 0
        self.inviteYesButton.backgroundColor = UIColor.white
        self.inviteYesButton.setTitleColor(.black, for: .normal)
        self.inviteNoButton.backgroundColor = UIColor.gray
        self.inviteNoButton.setTitleColor(.white, for: .normal)
    }
    
    @IBAction func statusOpenButtonAction(_ sender: Any) {
        self.status = "open"
        self.statusOpenButton.backgroundColor = UIColor.gray
        self.statusOpenButton.setTitleColor(.white, for: .normal)
        self.statusConfirmButton.backgroundColor = UIColor.white
        self.statusConfirmButton.setTitleColor(.black, for: .normal)
        self.statusCancelButton.backgroundColor = UIColor.white
        self.statusCancelButton.setTitleColor(.black, for: .normal)
    }
    
    @IBAction func statusConfirmButtonAction(_ sender: Any) {
        self.status = "confirm"
        self.statusOpenButton.backgroundColor = UIColor.white
        self.statusOpenButton.setTitleColor(.black, for: .normal)
        self.statusConfirmButton.backgroundColor = UIColor.gray
        self.statusConfirmButton.setTitleColor(.white, for: .normal)
        self.statusCancelButton.backgroundColor = UIColor.white
        self.statusCancelButton.setTitleColor(.black, for: .normal)
    }
    
    @IBAction func statusCancelButtonAction(_ sender: Any) {
        self.status = "cancel"
        self.statusOpenButton.backgroundColor = UIColor.white
        self.statusOpenButton.setTitleColor(.black, for: .normal)
        self.statusConfirmButton.backgroundColor = UIColor.white
        self.statusConfirmButton.setTitleColor(.black, for: .normal)
        self.statusCancelButton.backgroundColor = UIColor.gray
        self.statusCancelButton.setTitleColor(.white, for: .normal)
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
        let guest_name = self.guestNameTextField.text!
        let person_number_string = self.numberTextField.text!
        if(guest_name == "") {
            self.createAlert(title: "Plan Better", message: "Please input Name.")
            return
        }
        if(person_number_string == "") {
            self.createAlert(title: "Plan Better", message: "Please input number of person.")
            return
        }
        let person_number = Int(person_number_string)!
        self.startActivityIndicator()
        let currentDate = Date()
        
        if(self.selected_guest.isEmpty) {
            let post_data = [
                "guest_name": guest_name,
                "invited": self.invited,
                "status": self.status,
                "person_number": person_number,
                "createdAt": currentDate.timeIntervalSince1970,
                "party_key": Global.party_key
            ] as [String: Any]
            self.ref.childByAutoId().setValue(post_data, withCompletionBlock:
                {
                    error, ref in
                    if(error != nil) {
                        self.createAlert(title: "Plan Better", message: "Network Error")
                    } else {
                        self.guestNameTextField.text = ""
                        self.numberTextField.text = ""
                        self.invited = 1
                        self.inviteYesButton.backgroundColor = UIColor.gray
                        self.inviteYesButton.setTitleColor(.white, for: .normal)
                        self.inviteNoButton.backgroundColor = UIColor.white
                        self.inviteNoButton.setTitleColor(.black, for: .normal)
                        self.status = "open"
                        self.statusOpenButton.backgroundColor = UIColor.gray
                        self.statusOpenButton.setTitleColor(.white, for: .normal)
                        self.statusConfirmButton.backgroundColor = UIColor.white
                        self.statusConfirmButton.setTitleColor(.black, for: .normal)
                        self.statusCancelButton.backgroundColor = UIColor.white
                        self.statusCancelButton.setTitleColor(.black, for: .normal)
                    }
                    self.stopActivityIndicator()
                    self.navigationController?.popViewController(animated: true)
            })
        } else {
            let post_data = [
                "guest_name": guest_name,
                "invited": self.invited,
                "status": self.status,
                "person_number": person_number,
            ] as [String: Any]
            let createdAt = self.selected_guest["createdAt"] as! NSNumber
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
    
    @IBAction func cancelButton(_ sender: Any) {
        if(self.selected_guest.isEmpty) {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.startActivityIndicator()
            let createdAt = self.selected_guest["createdAt"] as! NSNumber
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
