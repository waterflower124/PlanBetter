//
//  CreateEventViewController.swift
//  PlanBetter
//
//  Created by wflower on 14/11/2019.
//  Copyright © 2019 waterflower. All rights reserved.
//

import UIKit
import Firebase

class CreateEventViewController: UIViewController {

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var partynameTextField: UITextField!
    @IBOutlet weak var partytypeTextField: UITextField!
    @IBOutlet weak var partyDatePicker: UIDatePicker!
    
    ///////   for activity indicator  //////////
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var overlayView:UIView = UIView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.saveButton.layer.borderWidth = 1
        self.saveButton.layer.borderColor = CGColor.init(srgbRed: 0, green: 0, blue: 0, alpha: 1)
        self.cancelButton.layer.borderWidth = 1
        self.cancelButton.layer.borderColor = CGColor.init(srgbRed: 0, green: 0, blue: 0, alpha: 1)
        partyDatePicker.minimumDate = Date()
        
        
        ////  dismiss keyboard   ///////
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        
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
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func saveAction(_ sender: Any) {
        let party_name = self.partynameTextField.text!
        let party_type = self.partytypeTextField.text!
        if(party_name == "") {
            self.createAlert(title: "Plan Better", message: "Please input Party Name.")
            return
        }
        if(party_type == "") {
            self.createAlert(title: "Plan Better", message: "Please input Party Type.")
            return
        }
        
        let partyDate = partyDatePicker.date
        let currentDate = Date()
        
        self.startActivityIndicator()
        let post_data = [
            "party_name": party_name,
            "party_type": party_type,
            "party_checked": false,
            "party_datetime": partyDate.timeIntervalSince1970,
            "createdAt": currentDate.timeIntervalSince1970
        ] as [String: Any]
        let ref = Database.database().reference().child("parties")
        ref.childByAutoId().setValue(post_data, withCompletionBlock:
            {
                error, ref in
                if(error != nil) {
                    self.createAlert(title: "Plan Better", message: "Network Error")
                } else {
                    
                }
                self.stopActivityIndicator()
                let month = Calendar.current.dateComponents([.month], from: currentDate, to: partyDate).month
                let day = Calendar.current.dateComponents([.day], from: currentDate, to: partyDate).day
                let hour = Calendar.current.dateComponents([.hour], from: currentDate, to: partyDate).hour
                let minute = Calendar.current.dateComponents([.minute], from: currentDate, to: partyDate).minute
                let second = Calendar.current.dateComponents([.second], from: currentDate, to: partyDate).second
                var alert_message = "There is "
                if (month! > 0) {
                    alert_message += String(month!) + " months "
                }
                if (day! - month! * 30 > 0) {
                    alert_message += String(day! - month! * 30) + " days "
                }
                if (hour! - day! * 24 > 0) {
                    alert_message += String(hour! - day! * 24) + " hours "
                }
                if (minute! - hour! * 60 > 0) {
                    alert_message += String(minute! - hour! * 60) + " minutes "
                }
                if (second! - minute! * 60 > 0) {
                    alert_message += String(second! - minute! * 60) + " seconds "
                }
                alert_message += "to your " + party_type + " party"
                
//                self.createAlert(title: "Plan Better", message: alert_message)
                self.navigationController?.popViewController(animated: true)
        })
        
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
