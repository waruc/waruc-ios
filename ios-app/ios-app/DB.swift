//
//  DB.swift
//  ios-app
//
//  Created by Nicholas Nordale on 5/17/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import Alamofire
import SwiftyJSON

class DB {
    
    var ref: FIRDatabaseReference!
    var feedRad: Int
    var refreshFeed: Bool!
    
    let vehicleInfoNotification = Notification.Name("vehicleInfoNotification")
    let fetchVehicleInfoNotification = Notification.Name("fetchVehicleInfoNotification")
    var vinData:[JSON] = []
    var currVehicleInfo:[String : String] = [
        "make": "",
        "model": "",
        "year": "",
        "nickname": ""
    ]
    
    var fetchVinData:[JSON] = []
    var fetchVehicleInfo:[String : String] = [
        "make": "",
        "model": "",
        "year": ""
    ]
    
    init() {
        self.ref = FIRDatabase.database().reference()
        self.feedRad = 5500
        self.refreshFeed = false
    }
    
    static let sharedInstance = DB()
    
    func getUserVehicles(results : @escaping ((_ vehicles : Array<Any>) -> Void)){
        if FIRAuth.auth()?.currentUser?.uid != nil {
            
            // fetch data from Firebase
            let uid = FIRAuth.auth()?.currentUser?.uid
            ref!.child("userVehicles").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                var vehicle_keys = [String]()
                let enumerator = snapshot.children
                while let rest = enumerator.nextObject() as? FIRDataSnapshot{
                    vehicle_keys.append(rest.key)
                }
                results(vehicle_keys)
            }, withCancel: nil)
        } else {
            print("Error fetching user vehicles")
        }
    }
    
    func registerVehicle(vin: String, make: String, model: String, year: String, nickname: String?) {
        let date = Date()
        let ts = Int(date.timeIntervalSince1970.rounded())
        
        let uid = FIRAuth.auth()?.currentUser?.uid
        
        let vehicle_values = [
            "make" : make,
            "model": model,
            "year": year,
            "users": uid!,
            "nickname": nickname ?? "",
            "cts": "\(ts)"
            ] as [String : Any]
        
        ref.child("vehicles").updateChildValues([vin : vehicle_values])
    }
    
    func createOrReturnVehicle(vin: String) {
        ref!.child("vehicles").child(vin).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                print("\nFound existing vehicle!")
                let existingVehicleInfo = snapshot.value as! [String: Any]
                
                self.currVehicleInfo["make"] = (existingVehicleInfo["make"] as! String)
                self.currVehicleInfo["model"] = (existingVehicleInfo["model"] as! String)
                self.currVehicleInfo["year"] = (existingVehicleInfo["year"] as! String)
                self.currVehicleInfo["nickname"] = (existingVehicleInfo["nickname"] as! String)
                
                self.updateVehicleUsers(vin: vin)
                self.updateUserVehicles(vin: vin)
                
                NotificationCenter.default.post(name: self.vehicleInfoNotification, object: nil)
            } else {
                print("\nCreating new vehicle...")
                Alamofire.request(self.vinLookupUrl(vin: vin), method: .get).validate().responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        self.vinData = json["Results"].arrayValue.filter { [26, 28, 29].contains($0["VariableId"].intValue) }
                        
                        self.currVehicleInfo["make"] = self.getVehicleAttrWithId(variableId: 26).capitalized
                        self.currVehicleInfo["model"] = self.getVehicleAttrWithId(variableId: 28)
                        self.currVehicleInfo["year"] = self.getVehicleAttrWithId(variableId: 29)
                        //self.currVehicleInfo["nickname"] = "Nick's Car"
                        
                        self.registerVehicle(vin: vin,
                                             make: self.currVehicleInfo["make"]!,
                                             model: self.currVehicleInfo["model"]!,
                                             year: self.currVehicleInfo["year"]!,
                                             nickname: self.currVehicleInfo["nickname"])
                        
                        self.updateVehicleUsers(vin: vin)
                        self.updateUserVehicles(vin: vin)
                        
                        print("Make: \(self.currVehicleInfo["make"]!)")
                        print("Model: \(self.currVehicleInfo["model"]!)")
                        print("Model Year: \(self.currVehicleInfo["year"]!)")
                        
                        NotificationCenter.default.post(name: self.vehicleInfoNotification, object: nil)
                        
                    case .failure(let error):
                        print("VIN Lookup Failure:")
                        print(error)
                    }
                }
            }
        })
        
    }
    
    func fetchVehicleInfo(vin: String) {
        Alamofire.request(self.vinLookupUrl(vin: vin), method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                self.fetchVinData = json["Results"].arrayValue.filter { [26, 28, 29].contains($0["VariableId"].intValue) }
                
                print(self.fetchVinData)
                
                self.fetchVehicleInfo["make"] = self.getFetchVehicleAttrWithId(variableId: 26).capitalized
                self.fetchVehicleInfo["model"] = self.getFetchVehicleAttrWithId(variableId: 28)
                self.fetchVehicleInfo["year"] = self.getFetchVehicleAttrWithId(variableId: 29)
                
                print("Make: \(self.fetchVehicleInfo["make"]!)")
                print("Model: \(self.fetchVehicleInfo["model"]!)")
                print("Model Year: \(self.fetchVehicleInfo["year"]!)")
                
                NotificationCenter.default.post(name: self.fetchVehicleInfoNotification, object: nil)
                
            case .failure(let error):
                print("VIN Lookup Failure:")
                print(error)
            }
        }
    }
    
    func updateVehicleUsers(vin: String) {
        let uid = FIRAuth.auth()?.currentUser?.uid
        
        ref!.child("vehicles").child("\(vin)/users/\(uid!)").observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                print("\nFound user for vehicle!")
            } else {
                print("\nCreating new user for vehicle...")
                let user_values = ["total_mileage": 0]
                self.ref.child("vehicles").child("\(vin)/users").updateChildValues([uid! : user_values])
            }
        })
    }
    
    func updateUserVehicles(vin: String) {
        let uid = FIRAuth.auth()?.currentUser?.uid
        
        ref!.child("userVehicles").child("\(uid!)/vehicles/\(vin)").observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                print("\nFound vehicle entry in user vehicles!")
            } else {
                print("\nCreating new entry in user vehicles...")
                self.ref.child("userVehicles/\(uid!)/vehicles").updateChildValues([vin: "owner"])
            }
        })
    }
    
    func vinLookupUrl(vin: String) -> String {
        return "https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVin/\(vin)*BA?format=json"
    }
    
    func getVehicleAttrWithId(variableId: Int) -> String {
        return vinData.filter { $0["VariableId"].intValue == variableId }[0]["Value"].stringValue
    }
    
    func getFetchVehicleAttrWithId(variableId: Int) -> String {
        return fetchVinData.filter { $0["VariableId"].intValue == variableId }[0]["Value"].stringValue
    }
    
    func writeTrip(ts: Int, miles:Double, vin: String, uid: String) {
        let key = self.ref.child("vehicles").childByAutoId().key
        let values = ["timestamp": ts, "mileage:": miles] as [String : Any]
        let updates = ["vehicles/\(vin)/users/\(uid)/trips/\(key)": values]
        ref.updateChildValues(updates)
        
        // update user total miles based off of current trip
        ref.child("userVehicles/\(uid)/total_miles").observeSingleEvent(of: .value, with: { (snapshot) in
            let total_miles = snapshot.value as! Double
            self.ref.child("userVehicles/\(uid)/total_miles").setValue(total_miles + miles)
        }, withCancel: nil)
        
    }
    
    func getTrips(vin: String, uid: String, results : @escaping ((_ trips : JSON) -> Void)) {
        ref.child("vehicles/\(vin)/users/\(uid)/trips").observeSingleEvent(of: .value, with: { (snapshot) in
            let trip_json = JSON(snapshot.value as Any)
            print("Trips: \(trip_json)")
            results(trip_json)
        }, withCancel: nil)
    }
}

