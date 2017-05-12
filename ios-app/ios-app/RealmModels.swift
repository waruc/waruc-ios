//
//  Trip.swift
//  ios-app
//
//  Created by Babbs, Dylan and ishansaksena on 4/30/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import Foundation
import RealmSwift


// MARK: Models
class Trip: Object {
    // Date and time
    dynamic var date = Date()
    // Distance travelled in this trip
    dynamic var distance = 0.0
    // ID for iPhone from Firebase
    dynamic var deviceID = ""
}

// MARK: Writing
let realm = try! Realm()

func writeTrip(date: Date, distance: Double, deviceID: String) {
    // Construct Realm model
    let trip = Trip()
    trip.date = date
    trip.distance = distance
    trip.deviceID = deviceID
    
    // Write object
    try! realm.write {
        realm.add(trip)
    }
}

// MARK: Reading
// Returns a Realm results object
// List of Trip objects
// Sorted by date of trip -> Most recent first
func readTrip() -> Results<Trip> {
    // Query Realm for all trips
    let trips = realm.objects(Trip.self).sorted(byKeyPath: "date", ascending: false)
    print("Read \(trips.count) trips for Realm")
    return trips
}
