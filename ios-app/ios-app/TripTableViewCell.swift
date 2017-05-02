//
//  TripTableViewCell.swift
//  ios-app
//
//  Created by ishansaksena on 5/2/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit

class TripTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel = UILabel()
    @IBOutlet weak var timeLabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
