//
//  ShoppingListViewController.swift
//  PlanBetter
//
//  Created by wflower on 28/11/2019.
//  Copyright © 2019 waterflower. All rights reserved.
//

import UIKit
import Firebase

class ShoppingListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var shoppinglistTableView: UITableView!

    
    var shopping_list = [Dictionary<String, Any>]()
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

        self.title = "Shpping List"
        self.shoppinglistTableView.separatorStyle = .none

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.startActivityIndicator()
        let ref = Database.database().reference()
        ref.child("shopping_list").queryOrdered(byChild: "createdAt").observe(.value, with: {(snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                self.shopping_list = []
                for snap in snapshot {
                    if let dic = snap.value as? Dictionary<String, Any> {
                        if(dic["party_key"] as? String == Global.party_key) {
                            self.shopping_list.append(dic)
                        }
                    }
                }
                
                self.shoppinglistTableView.reloadData()
            }
            self.stopActivityIndicator()
        })
    }
    
    @IBAction func addButtonAction(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let addshoplistoVC = mainStoryboard.instantiateViewController(withIdentifier: "AddShoppingListViewController") as! AddShoppingListViewController
        self.navigationController?.pushViewController(addshoplistoVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.shopping_list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shoppinglisttableviewcell") as! ShoppingListTableViewCell
        cell.goodsnameLabel.text = self.shopping_list[indexPath.row]["goods_name"] as? String
        if(self.shopping_list[indexPath.row]["bought_status"] as! Int == 1) {
            cell.checkButton.setImage(UIImage(named: "checkbox"), for: .normal)
        } else {
            cell.checkButton.setImage(UIImage(named: "uncheckbox"), for: .normal)
        }
        cell.checkboxButtonAction = {
            var bought_status = 0
            if (self.shopping_list[indexPath.row]["bought_status"] as! Int == 1) {
                cell.checkButton.setImage(UIImage(named: "uncheckbox"), for: .normal)
                bought_status = 0
            } else {
                cell.checkButton.setImage(UIImage(named: "checkbox"), for: .normal)
                bought_status = 1
            }
            
            self.startActivityIndicator()
            let post_data = [
                "bought_status": bought_status,
            ] as [String: Any]
            let createdAt = self.shopping_list[indexPath.row]["createdAt"] as! NSNumber
            self.ref.queryOrdered(byChild: "createdAt").queryEqual(toValue: createdAt).observeSingleEvent(of:.value, with:  { (snapshot) in
                for child in snapshot.children {
                    if let child = child as? DataSnapshot {
                        self.ref.child(child.key).updateChildValues(post_data)
                    }
                }
                 
                self.stopActivityIndicator()
            })
        }
        cell.containerView.backgroundColor = UIColor(red: 205/255, green: 124/255, blue: 201/255, alpha: 0.3)
        cell.containerView.layer.cornerRadius = 5
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let addshoplistoVC = mainStoryboard.instantiateViewController(withIdentifier: "AddShoppingListViewController") as! AddShoppingListViewController
        addshoplistoVC.selected_item = self.shopping_list[indexPath.row]
        self.navigationController?.pushViewController(addshoplistoVC, animated: true)
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
