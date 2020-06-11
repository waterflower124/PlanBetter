//
//  ToDoListViewController.swift
//  PlanBetter
//
//  Created by wflower on 17/11/2019.
//  Copyright © 2019 waterflower. All rights reserved.
//

import UIKit
import Firebase

class ToDoListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var topButtonView: UIView!
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var openButton: UIButton!
    @IBOutlet weak var todoListTableView: UITableView!
    
    var todolist_array = [Dictionary<String, Any>]()
    var display_array = [Dictionary<String, Any>]()
    
    ///////   for activity indicator  //////////
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var overlayView:UIView = UIView()
    
    var selected_type = "All"
    let currentDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.todoListTableView.separatorStyle = .none
        
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

        self.topButtonView.layer.borderWidth = 1
        self.topButtonView.layer.borderColor = CGColor.init(srgbRed: 0, green: 0, blue: 0, alpha: 1)
        self.topButtonView.layer.cornerRadius = 5
        
        self.allButton.backgroundColor = UIColor.gray
        self.allButton.setTitleColor(.white, for: .normal)
        self.doneButton.backgroundColor = UIColor.white
        self.doneButton.setTitleColor(.black, for: .normal)
        self.openButton.backgroundColor = UIColor.white
        self.openButton.setTitleColor(.black, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.startActivityIndicator()
        let ref = Database.database().reference()
        ref.child("to-do_list").queryOrdered(byChild: "createdAt").observe(.value, with: {(snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                self.todolist_array = []
                self.display_array = []
                for snap in snapshot {
                    if let dic = snap.value as? Dictionary<String, Any> {
                        if(dic["party_key"] as? String == Global.party_key) {
                            self.todolist_array.append(dic)
                        }
                    }
                }
                if(self.selected_type == "All") {
                    self.display_array = self.todolist_array
                } else if(self.selected_type == "Done") {
                    for i in 0 ..< self.todolist_array.count {
                        if(self.todolist_array[i]["open"] as! Int == 0) {
                            self.display_array.append(self.todolist_array[i])
                        }
                    }
                } else if(self.selected_type == "Open") {
                    for i in 0 ..< self.todolist_array.count {
                        if(self.todolist_array[i]["open"] as! Int == 1) {
                            self.display_array.append(self.todolist_array[i])
                        }
                    }
                }
                self.todoListTableView.reloadData()
            }
            self.stopActivityIndicator()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func allButtonAction(_ sender: Any) {
        self.selected_type = "All"
        self.allButton.backgroundColor = UIColor.gray
        self.allButton.setTitleColor(.white, for: .normal)
        self.doneButton.backgroundColor = UIColor.white
        self.doneButton.setTitleColor(.black, for: .normal)
        self.openButton.backgroundColor = UIColor.white
        self.openButton.setTitleColor(.black, for: .normal)
        
        self.display_array = self.todolist_array
        self.todoListTableView.reloadData()
    }
    
    @IBAction func doneButtonAction(_ sender: Any) {
        self.selected_type = "Done"
        self.allButton.backgroundColor = UIColor.white
        self.allButton.setTitleColor(.black, for: .normal)
        self.doneButton.backgroundColor = UIColor.gray
        self.doneButton.setTitleColor(.white, for: .normal)
        self.openButton.backgroundColor = UIColor.white
        self.openButton.setTitleColor(.black, for: .normal)
        
        self.display_array = []
        for i in 0 ..< self.todolist_array.count {
            if(self.todolist_array[i]["open"] as! Int == 0) {
                self.display_array.append(self.todolist_array[i])
            }
        }
        self.todoListTableView.reloadData()
    }
    
    @IBAction func openButtonAction(_ sender: Any) {
        self.selected_type = "Open"
        self.allButton.backgroundColor = UIColor.white
        self.allButton.setTitleColor(.black, for: .normal)
        self.doneButton.backgroundColor = UIColor.white
        self.doneButton.setTitleColor(.black, for: .normal)
        self.openButton.backgroundColor = UIColor.gray
        self.openButton.setTitleColor(.white, for: .normal)
        
        self.display_array = []
        for i in 0 ..< self.todolist_array.count {
            if(self.todolist_array[i]["open"] as! Int == 1) {
                self.display_array.append(self.todolist_array[i])
            }
        }
        self.todoListTableView.reloadData()
    }
    
    @IBAction func plusButtonAction(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let addToDoVC = mainStoryboard.instantiateViewController(withIdentifier: "AddToDoViewController") as! AddToDoViewController
        self.navigationController?.pushViewController(addToDoVC, animated: true)
    }
    
    @IBAction func shopButtonAction(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let shoplistoVC = mainStoryboard.instantiateViewController(withIdentifier: "ShoppingListViewController") as! ShoppingListViewController
        self.navigationController?.pushViewController(shoplistoVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.display_array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todolisttableviewcell") as! ToDoListTableViewCell
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        cell.nameLabel.text = self.display_array[indexPath.row]["todo_name"] as? String
        
        let milidate = self.display_array[indexPath.row]["todo_datetime"] as! NSNumber
        let convertedDate = Date(timeIntervalSince1970: TimeInterval(truncating: milidate))
        var days_left = true
        var first_date = Date()
        var second_date = Date()
        
        cell.containView.layer.cornerRadius = 5
        if(currentDate > convertedDate) {
            cell.containView.backgroundColor = UIColor(red: 205/255, green: 124/255, blue: 201/255, alpha: 0.3)
            days_left = false
            first_date = convertedDate
            second_date = currentDate
        } else {
            cell.containView.backgroundColor = UIColor(red: 164/255, green: 179/255, blue: 139/255, alpha: 0.3)
            first_date = currentDate
            second_date = convertedDate
        }
        let month = Calendar.current.dateComponents([.month], from: first_date, to: second_date).month
        let day = Calendar.current.dateComponents([.day], from: first_date, to: second_date).day
        let hour = Calendar.current.dateComponents([.hour], from: first_date, to: second_date).hour
        let minute = Calendar.current.dateComponents([.minute], from: first_date, to: second_date).minute
        let second = Calendar.current.dateComponents([.second], from: first_date, to: second_date).second
        if(month! > 0) {
            if(days_left) {
                cell.daysLabel.text = "in " + String(month!) + " month(s)"
            } else {
                cell.daysLabel.text = String(month!) + " month(s) ago"
            }
        } else if(day! > 0) {
            if(days_left) {
                cell.daysLabel.text = "in " + String(day!) + " day(s)"
            } else {
                cell.daysLabel.text = String(day!) + " day(s) ago"
            }
        } else if(hour! > 0) {
            if(days_left) {
                cell.daysLabel.text = "in " + String(hour!) + " hour(s)"
            } else {
                cell.daysLabel.text = String(hour!) + " hour(s) ago"
            }
        } else if(minute! > 0) {
            if(days_left) {
                cell.daysLabel.text = "in " + String(minute!) + " minute(s)"
            } else {
                cell.daysLabel.text = String(minute!) + " minute(s) ago"
            }
        } else {
            if(days_left) {
                cell.daysLabel.text = "in " + String(second!) + " second(s)"
            } else {
                cell.daysLabel.text = String(minute!) + " second(s) ago"
            }
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let editToDoVC = mainStoryboard.instantiateViewController(withIdentifier: "EditToDoViewController") as! EditToDoViewController
        editToDoVC.selected_todo = self.display_array[indexPath.row]
        self.navigationController?.pushViewController(editToDoVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
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
