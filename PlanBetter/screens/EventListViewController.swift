//
//  EventListViewController.swift
//  PlanBetter
//
//  Created by wflower on 14/11/2019.
//  Copyright © 2019 waterflower. All rights reserved.
//

import UIKit
import Firebase

class EventListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var eventlistTableView: UITableView!
    
    ///////   for activity indicator  //////////
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var overlayView:UIView = UIView()
    
    var event_array = [Dictionary<String, Any>]()
    
    let ref = Database.database().reference().child("parties")
    
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
        
        self.eventlistTableView.separatorStyle = .none

        self.startActivityIndicator()
        self.event_array = []
        self.ref.queryOrdered(byChild: "party_datetime").observeSingleEvent(of:.value, with: {(snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let dic = snap.value as? Dictionary<String, Any> {
                        self.event_array.append(dic)
                    }
                }
                self.eventlistTableView.reloadData()
                
            }
            self.stopActivityIndicator()
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.event_array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "partytableviewcell") as! PartyTableViewCell
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.partynameLabel.text = self.event_array[indexPath.row]["party_name"] as? String
        if (self.event_array[indexPath.row]["party_checked"] as! Bool) {
            cell.checkButton.setImage(UIImage(named: "checkbox"), for: .normal)
        } else {
            cell.checkButton.setImage(UIImage(named: "uncheckbox"), for: .normal)
        }
        
        cell.checkboxButtonAction = {
            if self.event_array[indexPath.row]["party_checked"] as! Bool {
                cell.checkButton.setImage(UIImage(named: "uncheckbox"), for: .normal)
                self.event_array[indexPath.row]["party_checked"] = false
                self.eventlistTableView.reloadData()
                Global.party_key = ""
                
                let post_data = [
                    "party_checked": false,
                ] as [String: Any]
                let createdAt = self.event_array[indexPath.row]["createdAt"] as! NSNumber
                self.ref.queryOrdered(byChild: "createdAt").queryEqual(toValue: createdAt).observeSingleEvent(of:.value, with:  { (snapshot) in
                    for child in snapshot.children {
                        if let child = child as? DataSnapshot {
                            self.ref.child(child.key).updateChildValues(post_data)
                        }
                    }

                })
            } else {
                cell.checkButton.setImage(UIImage(named: "checkbox"), for: .normal)
                
                for i in 0 ..< self.event_array.count {
                    if(i == indexPath.row) {
                        self.event_array[i]["party_checked"] = true
                    } else {
                        self.event_array[i]["party_checked"] = false
                    }
                }
                self.eventlistTableView.reloadData()
                
                var post_data = [
                    "party_checked": false,
                ] as [String: Any]
                self.ref.queryOrdered(byChild: "createdAt").observeSingleEvent(of:.value, with:  { (snapshot) in
                    for child in snapshot.children {
                        if let child = child as? DataSnapshot {
                            self.ref.child(child.key).updateChildValues(post_data)
                        }
                    }

                    post_data = [
                        "party_checked": true,
                    ] as [String: Any]
                    let createdAt = self.event_array[indexPath.row]["createdAt"] as! NSNumber
                    self.ref.queryOrdered(byChild: "createdAt").queryEqual(toValue: createdAt).observeSingleEvent(of:.value, with:  { (snapshot) in
                        for child in snapshot.children {
                            if let child = child as? DataSnapshot {
                                self.ref.child(child.key).updateChildValues(post_data)
                                Global.party_key = child.key
                            }
                        }

                    })

                })
            }
        }
        
        cell.removeButtonAction = {
            let createdAt = self.event_array[indexPath.row]["createdAt"] as! NSNumber
            self.ref.queryOrdered(byChild: "createdAt").queryEqual(toValue: createdAt).observeSingleEvent(of:.value, with:  { (snapshot) in
                for child in snapshot.children {
                    if let child = child as? DataSnapshot {
                        self.ref.child(child.key).setValue(nil)
                    }
                }
                self.event_array.remove(at: indexPath.row)
                self.eventlistTableView.reloadData()
            })
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("aaaa")
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
