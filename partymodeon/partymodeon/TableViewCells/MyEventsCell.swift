//
//  MyEventsCell.swift
//  partymodeon
//
//  Created by Varun Srinivasan on 11/25/17.
//  Copyright © 2017 Varun Srinivasan. All rights reserved.
//

import UIKit

class MyEventsCell: UITableViewCell {

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
