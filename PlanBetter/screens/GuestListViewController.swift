//
//  GuestListViewController.swift
//  PlanBetter
//
//  Created by wflower on 18/11/2019.
//  Copyright © 2019 waterflower. All rights reserved.
//

import UIKit
import Firebase

class GuestListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var guestlistTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    var guest_array = [Dictionary<String, Any>]()
    var display_guest_array = [Dictionary<String, Any>]()
    var search_text = ""
    
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
        
        self.searchView.layer.cornerRadius = 5
        
        self.guestlistTableView.separatorStyle = .none

        ////  dismiss keyboard   ///////
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        self.startActivityIndicator()
        let ref = Database.database().reference()
        ref.child("guest_list").queryOrdered(byChild: "createdAt").observe(.value, with: {(snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                self.guest_array = []
                
                for snap in snapshot {
                    if let dic = snap.value as? Dictionary<String, Any> {
                        if(dic["party_key"] as? String == Global.party_key) {
                            self.guest_array.append(dic)
                        }
                    }
                }
                self.search_guest()
            }
            self.stopActivityIndicator()
        })
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.search_text = self.searchTextField.text!
        self.search_guest()
    }
    
    func search_guest() {
        self.display_guest_array = []
        if(self.search_text == "") {
            self.display_guest_array = self.guest_array
        } else {
            for i in 0 ..< self.guest_array.count {
                let name = self.guest_array[i]["guest_name"] as! String
                if(name.contains(self.search_text)) {
                    self.display_guest_array.append(self.guest_array[i])
                }
            }
        }
        self.guestlistTableView.reloadData()
    }
    
    @IBAction func plusButtonAction(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let addGuestVC = mainStoryboard.instantiateViewController(withIdentifier: "AddGuestViewController") as! AddGuestViewController
        
        self.navigationController?.pushViewController(addGuestVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.display_guest_array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "guestlisttableviewcell") as! GuestListTableViewCell
        cell.containView.backgroundColor = UIColor(red: 164/255, green: 179/255, blue: 139/255, alpha: 0.3)
        cell.containView.layer.cornerRadius = 5
        cell.nameLabel!.text = self.display_guest_array[indexPath.row]["guest_name"] as? String
        cell.numberLabel.text = String(self.display_guest_array[indexPath.row]["person_number"] as! Int)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let addGuestVC = mainStoryboard.instantiateViewController(withIdentifier: "AddGuestViewController") as! AddGuestViewController
        addGuestVC.selected_guest = self.display_guest_array[indexPath.row]
        self.navigationController?.pushViewController(addGuestVC, animated: true)
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
