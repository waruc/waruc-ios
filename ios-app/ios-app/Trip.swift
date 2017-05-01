//
//  Trip.swift
//  ios-app
//
//  Created by Babbs, Dylan on 4/30/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import Foundation

class Trip {
    var date: Date
    var distance: Double
    
    init(date: Date, distance: Double) {
        self.date = date
        self.distance = distance
    }
}
