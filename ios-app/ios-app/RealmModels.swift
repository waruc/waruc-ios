//
//  Trip.swift
//  ios-app
//
//  Created by Babbs, Dylan and ishansaksena on 4/30/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import Foundation
import RealmSwift

class Trip: Object {
    // Date and time
    dynamic var date = Date()
    // Distance travelled in this trip
    dynamic var distance = 0.0
    // ID for iPhone from Firebase
    dynamic var deviceID = ""
}
