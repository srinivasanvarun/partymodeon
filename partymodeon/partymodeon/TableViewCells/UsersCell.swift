//
//  UsersCell.swift
//  partymodeon
//
//  Created by Varun Srinivasan on 12/6/17.
//  Copyright © 2017 Varun Srinivasan. All rights reserved.
//

import UIKit

class UsersCell: UITableViewCell {

    @IBOutlet weak var UserName: UILabel!
    @IBOutlet weak var userselected: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
