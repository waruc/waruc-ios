//
//  mock.swift
//  ios-app
//
//  Created by Babbs, Dylan on 6/3/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import Foundation
import RealmSwift

class Trips: Object {
    let trips = List<Trip>()
    
    func save() {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(self)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
}

class Trip: Object {
    dynamic var timestamp = Date()
    dynamic var distance = Double()
    
    func save() {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(self)
            }
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }

}

