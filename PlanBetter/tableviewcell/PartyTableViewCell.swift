//
//  PartyTableViewCell.swift
//  PlanBetter
//
//  Created by wflower on 19/11/2019.
//  Copyright © 2019 waterflower. All rights reserved.
//

import UIKit

class PartyTableViewCell: UITableViewCell {

    @IBOutlet weak var partynameLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    
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
    
    var removeButtonAction: (() -> Void)? = nil
    @IBAction func removeButtonTap(_ sender: Any) {
        removeButtonAction?()
    }
    
}
