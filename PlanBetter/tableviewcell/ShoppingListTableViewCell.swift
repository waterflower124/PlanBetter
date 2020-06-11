//
//  ShoppingListTableViewCell.swift
//  PlanBetter
//
//  Created by wflower on 28/11/2019.
//  Copyright © 2019 waterflower. All rights reserved.
//

import UIKit

class ShoppingListTableViewCell: UITableViewCell {

    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var goodsnameLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var checkboxButtonAction: (() -> Void)? = nil
    @IBAction func checkboxButtonTap(_ sender: Any) {
        checkboxButtonAction?()
    }

}
