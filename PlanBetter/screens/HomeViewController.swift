//
//  HomeViewController.swift
//  PlanBetter
//
//  Created by wflower on 14/11/2019.
//  Copyright © 2019 waterflower. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {

    @IBOutlet weak var chooseButton: UIButton!
    @IBOutlet weak var eventView: UIView!
    @IBOutlet weak var createeventButton: UIButton!
    @IBOutlet weak var partyDateLabel: UILabel!
    @IBOutlet weak var differenceLabel: UILabel!
    @IBOutlet weak var partyNameLabel: UILabel!
    
   ///////   for activity indicator  //////////
   var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
   var overlayView:UIView = UIView()
    
    var timer = Timer()
    var event_datetime = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.chooseButton.layer.borderWidth = 1
        self.chooseButton.layer.borderColor = CGColor.init(srgbRed: 0, green: 0, blue: 0, alpha: 1)
        eventView.layer.cornerRadius = 10
        createeventButton.layer.borderWidth = 1
        createeventButton.layer.borderColor = CGColor.init(srgbRed: 0, green: 0, blue: 0, alpha: 1)
        
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
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.startActivityIndicator()
        let ref = Database.database().reference()
        ref.child("parties").queryOrdered(byChild: "party_datetime").observe(.value, with: {(snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let dic = snap.value as? Dictionary<String, Any> {
                        if(dic["party_checked"] != nil && dic["party_checked"] as! Bool) {
                            if dic["party_name"] != nil {
                                self.partyNameLabel.text = (dic["party_name"] as? String)! + " Party"
                            }
                            if dic["party_datetime"] != nil {
                                let milidate = dic["party_datetime"] as! Int
                                let convertedDate = Date(timeIntervalSince1970: TimeInterval(milidate))
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "EEEE, MMMM d, yyyy hh:mm a"
                                self.partyDateLabel.text = dateFormatter.string(from: convertedDate)
                                self.show_countdown(convertedDate: convertedDate)
                                self.event_datetime = convertedDate
                                
                                self.timer.invalidate() // just in case this button is tapped multiple times

                                    // start the timer
                                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true)
                                
                                break
                            }
                        } else {
                            self.timer.invalidate() // just in case this button is tapped multiple times
                            self.partyNameLabel.text = "Party"
                            self.partyDateLabel.text = ""
                            self.differenceLabel.text = ""
                        }
                    }
                }
            }
            self.stopActivityIndicator()
        }, withCancel: {error in
            print(error)
            self.stopActivityIndicator()
        })
    }
    
    @objc func timerAction() {
        self.show_countdown(convertedDate: self.event_datetime)
    }
    
    func show_countdown(convertedDate: Date) {
        let currentDate = Date()
        let month = Calendar.current.dateComponents([.month], from: currentDate, to: convertedDate).month
        let day = Calendar.current.dateComponents([.day], from: currentDate, to: convertedDate).day
        let hour = Calendar.current.dateComponents([.hour], from: currentDate, to: convertedDate).hour
        let minute = Calendar.current.dateComponents([.minute], from: currentDate, to: convertedDate).minute
        let second = Calendar.current.dateComponents([.second], from: currentDate, to: convertedDate).second
        var difflabel_message = "in "
        if (month! > 0) {
            difflabel_message += String(month!) + " months "
        }
        if (day! - month! * 30 > 0) {
            difflabel_message += String(day! - month! * 30) + " days "
        }
        if (hour! - day! * 24 > 0) {
            difflabel_message += String(hour! - day! * 24) + " hours "
        }
        if (minute! - hour! * 60 > 0) {
            difflabel_message += String(minute! - hour! * 60) + " minutes "
        }
        if (second! - minute! * 60 > 0) {
            difflabel_message += String(second! - minute! * 60) + " seconds "
        }
        self.differenceLabel.text = difflabel_message
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func createEventAction(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let createEventVC = mainStoryboard.instantiateViewController(withIdentifier: "CreateEventViewController") as! CreateEventViewController
        self.navigationController?.pushViewController(createEventVC, animated: true)
    }
    
    @IBAction func chooseAction(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let eventlistVC = mainStoryboard.instantiateViewController(withIdentifier: "EventListViewController") as! EventListViewController
        self.navigationController?.pushViewController(eventlistVC, animated: true)
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
