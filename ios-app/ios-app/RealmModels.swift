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
    dynamic var ts = 0
    dynamic var distance = 0.0
    dynamic var duration = 0.0
    dynamic var vehicleVIN = ""
}

let realm = try! Realm()

func writeTrip(ts: Int, distance: Double, duration: Double, vehicleVIN: String) {
    let trip = Trip()
    trip.ts = ts
    trip.distance = distance
    trip.duration = duration
    trip.vehicleVIN = vehicleVIN
    
    try! realm.write {
        realm.add(trip)
    }
}

// Returns a Realm results object w/ trips sorted by ts
func readTrip() -> Results<Trip> {
    let trips = realm.objects(Trip.self).sorted(byKeyPath: "ts", ascending: false)
    print("Read \(trips.count) trips for Realm")
    return trips
}
