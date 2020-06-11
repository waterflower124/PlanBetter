//
//  ExpensesListViewController.swift
//  PlanBetter
//
//  Created by wflower on 18/11/2019.
//  Copyright © 2019 waterflower. All rights reserved.
//

import UIKit
import Firebase

class ExpensesListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var expensesTableView: UITableView!
    @IBOutlet weak var unpaidLabel: UILabel!
    @IBOutlet weak var totalcostLabel: UILabel!
    
    var expenses_array = [Dictionary<String, Any>]()
    
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

        self.expensesTableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        var unpaid_cost = 0
        var total_cost = 0
        self.startActivityIndicator()
        let ref = Database.database().reference()
        ref.child("expenses_list").queryOrdered(byChild: "createdAt").observe(.value, with: {(snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                self.expenses_array = []
                for snap in snapshot {
                    if let dic = snap.value as? Dictionary<String, Any> {
                        if(dic["party_key"] as? String == Global.party_key) {
                            self.expenses_array.append(dic)
                            total_cost += dic["expense_cost"] as! Int
                            if(dic["paid"] as! Int == 0) { // unpaid
                                unpaid_cost += dic["expense_cost"] as! Int
                            }
                        }
                    }
                }
                self.unpaidLabel.text = "Cost unpaid: $" + String(unpaid_cost)
                self.totalcostLabel.text = "Total cost: $" + String(total_cost)
                self.expensesTableView.reloadData()
            }
            self.stopActivityIndicator()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func plusButtonAction(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let addExpensesVC = mainStoryboard.instantiateViewController(withIdentifier: "AddExpensesViewController") as! AddExpensesViewController
        self.navigationController?.pushViewController(addExpensesVC, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.expenses_array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "expensetableviewcell") as! ExpenseTableViewCell
        cell.containerUIView.backgroundColor = UIColor(red: 205/255, green: 124/255, blue: 201/255, alpha: 0.3)
        cell.containerUIView.layer.cornerRadius = 5
        cell.nameLabel.text = self.expenses_array[indexPath.row]["expense_name"] as? String
        cell.costLabel.text = "$" + String(self.expenses_array[indexPath.row]["expense_cost"] as! Int)

        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let addExpensesVC = mainStoryboard.instantiateViewController(withIdentifier: "AddExpensesViewController") as! AddExpensesViewController
        addExpensesVC.selected_expense = self.expenses_array[indexPath.row]
        self.navigationController?.pushViewController(addExpensesVC, animated: true)
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
