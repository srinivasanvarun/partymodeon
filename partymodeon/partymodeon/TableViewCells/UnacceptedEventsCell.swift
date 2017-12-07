//
//  UnacceptedEventsCell.swift
//  partymodeon
//
//  Created by Varun Srinivasan on 12/5/17.
//  Copyright © 2017 Varun Srinivasan. All rights reserved.
//

import UIKit

class UnacceptedEventsCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
