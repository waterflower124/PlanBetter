//
//  GuestListTableViewCell.swift
//  PlanBetter
//
//  Created by wflower on 27/11/2019.
//  Copyright © 2019 waterflower. All rights reserved.
//

import UIKit

class GuestListTableViewCell: UITableViewCell {

    @IBOutlet weak var containView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
