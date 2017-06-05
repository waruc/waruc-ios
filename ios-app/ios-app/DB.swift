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
    
    let tripsNotification = Notification.Name("tripsNotification")
    let existingVehicleInfoNotification = Notification.Name("existingVehicleInfoNotification")
    let newVehicleInfoNotification = Notification.Name("newVehicleInfoNotification")
    let newVehicleAlertNotification = Notification.Name("newVehicleAlertNotification")
    
    var userVehicles:[String: [String: String]] = [:]
    
    var vinData:[JSON] = []
    var currVehicleInfo:[String: String]?
    
    var userTrips:[[String: Any]]?
    var userTotalMiles:Double?
    
    var newVehicle = false
    var showAddVehicleAlert = true
    
    var tripsTableSelectedRow = 0
    
    private init() {
        self.ref = FIRDatabase.database().reference()
        fetchUserVehicles()
        seedTrips()
    }
    
    static let sharedInstance = DB()
    
    func clearData() {
        userVehicles = [:]
        vinData = []
        currVehicleInfo = nil
        userTrips = nil
        newVehicle = false
        showAddVehicleAlert = true
        tripsTableSelectedRow = 0
    }
    
    func createSingleton() {
        print("Creating DB singleton...")
        fetchUserVehicles()
        seedTrips()
    }
    
    func fetchUserVehicles() {
        let uid = FIRAuth.auth()?.currentUser?.uid
        if uid != nil {
            ref!.child("users/\(uid!)").child("vehicles").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    let vehicles = snapshot.value as! [String: String]
                    self.userVehicles = [:]
                
                    for key in vehicles.keys {
                        self.userVehicles[key] = [:]
                    }
                    
                    print(self.userVehicles)
                    self.getUserVehicleInfo()
                }
                
            })
        } else {
            print("User isn't authenticated")
        }
    }
    
    func fetchUserTrips(completionHandler: @escaping (_ returnedTrips: [[String: Any]]) -> ()) {
        let uid = FIRAuth.auth()?.currentUser?.uid
        if uid != nil {
            ref!.child("users/\(uid!)").child("trips").observeSingleEvent(of: .value, with: { (snapshot) in
                var returnedTrips:[[String: Any]] = []
                
                if snapshot.exists() {
                    returnedTrips = Array((snapshot.value as! [String: [String: Any]]).values)
                }
                
                completionHandler(returnedTrips)
            })
        } else {
            print("User isn't authenticated")
        }
    }
    
    func fetchUserTripsByVin(vin: String, completionHandler: @escaping (_ returnedTrips: [[String: Any]]) -> ()) {
        let uid = FIRAuth.auth()?.currentUser?.uid
        if uid != nil {
            ref!.child("users/\(uid!)").child("trips").queryOrdered(byChild: "vin").queryEqual(toValue: vin).observeSingleEvent(of: .value, with: { (snapshot) in
                var returnedTrips:[[String: Any]] = []
                
                if snapshot.exists() {
                    returnedTrips = Array((snapshot.value as! [String: [String: Any]]).values)
                }
                
                completionHandler(returnedTrips)
            })
        } else {
            print("User isn't authenticated")
        }
    }
    
    func seedTrips() {
        let uid = FIRAuth.auth()?.currentUser?.uid
        if uid != nil {
            ref?.child("users/\(uid!)/trips").queryLimited(toFirst: 100).observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.exists() {
                    self.userTrips = Array((snapshot.value as! [String: [String: Any]]).values)
                } else {
                    self.userTrips = []
                }
                
                NotificationCenter.default.post(name: self.tripsNotification, object: nil)
            })
        }
    }
    
    func getUserVehicleInfo() {
        for key in userVehicles.keys {
            ref!.child("vehicles").child(key).observeSingleEvent(of: .value, with: { (snapshot) in
                let existingVehicleInfo = snapshot.value as! [String: Any]
                let vehicle:[String: String] = [
                    "vin": key,
                    "make": (existingVehicleInfo["make"] as! String),
                    "model": (existingVehicleInfo["model"] as! String),
                    "year": (existingVehicleInfo["year"] as! String),
                    "nickname": (existingVehicleInfo["nickname"] as! String)
                ]
                
                self.userVehicles[key] = vehicle
                
                // Set default car for Location tracking users
                if UserDefaults.standard.value(forKey: "ble_tracking") == nil &&
                    UserDefaults.standard.value(forKey: "location_tracking") != nil &&
                    Array(self.userVehicles.keys).index(of: key) == 0 {
                    
                    if self.currVehicleInfo == nil {
                        self.currVehicleInfo = self.userVehicles[key]
                        NotificationCenter.default.post(name: self.existingVehicleInfoNotification, object: nil)
                    }
                }
            })
        }
    }
    
    func registerVehicle() {
        print("Creating new vehicle...")
        let date = Date()
        let ts = Int(date.timeIntervalSince1970.rounded())
        
        let uid = FIRAuth.auth()?.currentUser?.uid
        
        var vehicle_values = [
            "make" : currVehicleInfo!["make"]!,
            "model": currVehicleInfo!["model"]!,
            "year": currVehicleInfo!["year"]!,
            "nickname": currVehicleInfo!["nickname"] ?? ""
            ] as [String : Any]
        
        if currVehicleInfo!["vin"] != nil {
            userVehicles[currVehicleInfo!["vin"]!] = (vehicle_values as! [String : String])
        } else {
            currVehicleInfo!["vin"] = "\(currVehicleInfo!["make"]!)\(currVehicleInfo!["model"]!)\(currVehicleInfo!["year"]!)\(ts)"
            userVehicles[currVehicleInfo!["vin"]!] = (vehicle_values as! [String : String])
        }
        
        vehicle_values["users"] =  uid!
        vehicle_values["vehicle_mileage"] =  0.0
        vehicle_values["cts"] = "\(ts)"
        
        ref.child("vehicles").updateChildValues([currVehicleInfo!["vin"]! : vehicle_values])
    }
    
    func createOrReturnVehicle(vin: String) {
        self.currVehicleInfo = [String: String]()
        self.currVehicleInfo!["vin"] = vin
        ref!.child("vehicles").child(vin).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                print("\nFound existing vehicle!")
                let existingVehicleInfo = snapshot.value as! [String: Any]
                
                self.currVehicleInfo!["make"] = (existingVehicleInfo["make"] as! String)
                self.currVehicleInfo!["model"] = (existingVehicleInfo["model"] as! String)
                self.currVehicleInfo!["year"] = (existingVehicleInfo["year"] as! String)
                self.currVehicleInfo!["nickname"] = (existingVehicleInfo["nickname"] as! String)
                
                print("\nMake: \(self.currVehicleInfo!["make"]!)")
                print("Model: \(self.currVehicleInfo!["model"]!)")
                print("Model Year: \(self.currVehicleInfo!["year"]!)")
                if self.currVehicleInfo!["nickname"] != "" {
                    print("Vehicle Nickname: \(self.currVehicleInfo!["nickname"]!)")
                }
                
                if !(self.userVehicles.keys.contains(vin)) && self.showAddVehicleAlert {
                    NotificationCenter.default.post(name: self.newVehicleAlertNotification, object: nil)
                }
                
                if self.userVehicles.keys.contains(vin) {
                    NotificationCenter.default.post(name: self.existingVehicleInfoNotification, object: nil)
                }
                
                NotificationCenter.default.post(name: self.newVehicleInfoNotification, object: nil)
            } else {
                print("\nFetching new vehicle info...")
                self.newVehicle = true
                self.fetchVehicleInfo()
            }
        })
        
    }
    
    func fetchVehicleInfo() {
        Alamofire.request(self.vinLookupUrl(vin: self.currVehicleInfo!["vin"]!), method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                self.vinData = json["Results"].arrayValue.filter { [26, 28, 29].contains($0["VariableId"].intValue) }
                
                self.currVehicleInfo!["make"] = self.getVehicleAttrWithId(variableId: 26).capitalized
                self.currVehicleInfo!["model"] = self.getVehicleAttrWithId(variableId: 28)
                self.currVehicleInfo!["year"] = self.getVehicleAttrWithId(variableId: 29)
                
                print("\nMake: \(self.currVehicleInfo!["make"]!)")
                print("Model: \(self.currVehicleInfo!["model"]!)")
                print("Model Year: \(self.currVehicleInfo!["year"]!)")
                
                if !(self.userVehicles.keys.contains(self.currVehicleInfo!["vin"]!)) && self.showAddVehicleAlert {
                    NotificationCenter.default.post(name: self.newVehicleAlertNotification, object: nil)
                }
                
                if self.userVehicles.keys.contains(self.currVehicleInfo!["vin"]!) {
                    NotificationCenter.default.post(name: self.existingVehicleInfoNotification, object: nil)
                }
                
                NotificationCenter.default.post(name: self.newVehicleInfoNotification, object: nil)
                
            case .failure(let error):
                print("VIN Lookup Failure:")
                print(error)
            }
        }
    }
    
    func updateVehicleUsers() {
        let uid = FIRAuth.auth()?.currentUser?.uid
        ref!.child("vehicles").child("\(self.currVehicleInfo!["vin"]!)/users/\(uid!)").observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                print("\nFound user for vehicle!")
            } else {
                print("\nCreating new user for vehicle...")
                let user_values = ["vehicle_user_mileage": 0]
                self.ref.child("vehicles").child("\(self.currVehicleInfo!["vin"]!)/users/\(uid!)").setValue(user_values)
            }
        })
    }
    
    func updateUserVehicles() {
        let uid = FIRAuth.auth()?.currentUser?.uid
        ref!.child("users").child("\(uid!)/vehicles/\(self.currVehicleInfo!["vin"]!)").observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                print("\nFound vehicle entry in user vehicles!")
            } else {
                print("\nCreating new entry in user vehicles...")
                self.ref.child("users/\(uid!)/vehicles").updateChildValues([self.currVehicleInfo!["vin"]!: "owner"])
            }
        })
    }
    
    func vinLookupUrl(vin: String) -> String {
        return "https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVin/\(vin)*BA?format=json"
    }
    
    func getVehicleAttrWithId(variableId: Int) -> String {
        return vinData.filter { $0["VariableId"].intValue == variableId }[0]["Value"].stringValue
    }
    
    func writeTrip(miles: Double, vin: String) {
        let date = Date()
        let ts = Int(date.timeIntervalSince1970.rounded())
        
        let uid = FIRAuth.auth()?.currentUser?.uid
        let key = self.ref.child("vehicles").childByAutoId().key
        let values = ["timestamp": ts, "mileage": miles, "vin": vin] as [String : Any]
        let updates = ["users/\(uid!)/trips/\(key)": values]
        ref.updateChildValues(updates)
        
        // update vehicle total miles based off of current trip
        ref.child("vehicles/\(vin)/vehicle_mileage").observeSingleEvent(of: .value, with: { (snapshot) in
            let vehicle_mileage = snapshot.value as! Double
            self.ref.child("vehicles/\(vin)/vehicle_mileage").setValue(vehicle_mileage + miles)
        })
        
        // update vehicle/user total miles based off of current trip
        ref.child("vehicles/\(vin)/users/\(uid!)/vehicle_user_mileage").observeSingleEvent(of: .value, with: { (snapshot) in
            let vehicle_user_mileage = snapshot.value as! Double
            self.ref.child("vehicles/\(vin)/users/\(uid!)/vehicle_user_mileage").setValue(vehicle_user_mileage + miles)
        })
        
        // update user total miles based off of current trip
        ref.child("users/\(uid!)").observeSingleEvent(of: .value, with: { (snapshot) in
            let user = snapshot.value as! [String: Any]
            self.ref.child("users/\(uid!)/user_mileage").setValue((user["user_mileage"] as! Double) + miles)
        })
    }
    
}

