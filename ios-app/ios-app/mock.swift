//
//  mock.swift
//  ios-app
//
//  Created by Babbs, Dylan on 6/3/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import Foundation
import RealmSwift

// Run Model
class Trip: Object {
    dynamic var timestamp = Date()
    let locations = List<Location>()
    
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

// Location Model
class Location: Object {
    dynamic var timestamp = Date()
    dynamic var latitude : Float = 0.0
    dynamic var longitude : Float = 0.0
    
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
