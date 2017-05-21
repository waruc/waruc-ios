//
//  TripTableViewCell.swift
//  ios-app
//
//  Created by Nicholas Nordale on 5/2/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit

class TripTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var orangeCalendarBox: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.orangeCalendarBox.layer.cornerRadius = 6.0
        self.orangeCalendarBox.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
