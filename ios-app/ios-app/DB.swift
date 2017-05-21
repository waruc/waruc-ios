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
    
    let tripsNotification = Notification.Name("tripsNotification")
    let existingVehicleInfoNotification = Notification.Name("existingVehicleInfoNotification")
    let newVehicleInfoNotification = Notification.Name("newVehicleInfoNotification")
    
    var userVehicleKeys:[String] = []
    var userVehicles:[[String: String]] = []
    
    var vinData:[JSON] = []
    var currVehicleInfo:[String: String]?
    
    var userTrips:[[String: Any]] = []
    
    var userTotalMiles:Double?
    var userTripCount:Int?
    
    init() {
        self.ref = FIRDatabase.database().reference()
        self.feedRad = 5500
        self.refreshFeed = false
    }
    
    static let sharedInstance = DB()
    
    func getUserVehicles() {
        let uid = FIRAuth.auth()?.currentUser?.uid
        if uid != nil {
            ref!.child("userVehicles").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                let userObj = snapshot.value as! [String: Any]
                self.userTripCount = (userObj["trips"] as! Int)
                
                let userVehicleArray = userObj["vehicles"] as! [String: String]
                self.userVehicleKeys = [String](userVehicleArray.keys)
                self.getTrips()
                self.getUserVehicleInfo()
            })
        } else {
            print("User isn't authenticated")
        }
    }
    
    func getTrips() {
        let uid = FIRAuth.auth()?.currentUser?.uid
        self.userTrips = []
        for key in userVehicleKeys {
            ref.child("vehicles/\(key)/users/\(uid!)/trips").observeSingleEvent(of: .value, with: { (snapshot) in
                let returnedTrips = (snapshot.value as! [String: Any])
                
                for (_, value) in returnedTrips {
                    var trip = (value as! [String: Any])
                    trip = ["ts": trip["timestamp"]!, "distance": (trip["mileage"]! as! Double)]
                    self.userTrips.append(trip)
                }
                
                if self.userTrips.count == self.userTripCount {
                    self.userTrips = self.userTrips.sorted(by: { ($0["ts"]! as! Int) > ($1["ts"]! as! Int) })
                    NotificationCenter.default.post(name: self.tripsNotification, object: nil)
                    print("\nRetrieved all user's trips")
                }
            })
        }
    }
    
    func getUserVehicleInfo() {
        self.userVehicles = []
        for key in userVehicleKeys {
            ref!.child("vehicles").child(key).observeSingleEvent(of: .value, with: { (snapshot) in
                let existingVehicleInfo = snapshot.value as! [String: Any]
                let vehicle:[String: String] = [
                    "make": (existingVehicleInfo["make"] as! String),
                    "model": (existingVehicleInfo["model"] as! String),
                    "year": (existingVehicleInfo["year"] as! String),
                    "nickname": (existingVehicleInfo["nickname"] as! String)
                ]
                
                self.userVehicles.append(vehicle)
                
                if self.userVehicles.count == self.userVehicleKeys.count {
                    print("\nRetrieved all user's vehicles")
                }
            })
        }
    }
    
    func registerVehicle(nickname: String?) {
        let date = Date()
        let ts = Int(date.timeIntervalSince1970.rounded())
        
        let uid = FIRAuth.auth()?.currentUser?.uid
        
        let vehicle_values = [
            "make" : currVehicleInfo!["make"]!,
            "model": currVehicleInfo!["model"]!,
            "year": currVehicleInfo!["year"]!,
            "users": uid!,
            "nickname": nickname ?? "",
            "vehicle_mileage": 0.0,
            "cts": "\(ts)"
            ] as [String : Any]
        
        ref.child("vehicles").updateChildValues([currVehicleInfo!["vin"]! : vehicle_values])
    }
    
    func createOrReturnVehicle(vin: String) {
        ref!.child("vehicles").child(vin).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                print("\nFound existing vehicle!")
                let existingVehicleInfo = snapshot.value as! [String: Any]
                
                self.currVehicleInfo = [String: String]()
                self.currVehicleInfo!["vin"] = vin
                self.currVehicleInfo!["make"] = (existingVehicleInfo["make"] as! String)
                self.currVehicleInfo!["model"] = (existingVehicleInfo["model"] as! String)
                self.currVehicleInfo!["year"] = (existingVehicleInfo["year"] as! String)
                self.currVehicleInfo!["nickname"] = (existingVehicleInfo["nickname"] as! String) == "" ? nil : (existingVehicleInfo["nickname"] as! String)
                
                NotificationCenter.default.post(name: self.existingVehicleInfoNotification, object: nil)
            } else {
                print("\nCreating new vehicle...")
                self.fetchVehicleInfo(vin: vin)
            }
            
            self.updateVehicleUsers(vin: vin)
            self.updateUserVehicles(vin: vin)
        })
        
    }
    
    func fetchVehicleInfo(vin: String) {
        Alamofire.request(self.vinLookupUrl(vin: vin), method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                self.vinData = json["Results"].arrayValue.filter { [26, 28, 29].contains($0["VariableId"].intValue) }
                
                self.currVehicleInfo = [String: String]()
                self.currVehicleInfo!["make"] = self.getVehicleAttrWithId(variableId: 26).capitalized
                self.currVehicleInfo!["model"] = self.getVehicleAttrWithId(variableId: 28)
                self.currVehicleInfo!["year"] = self.getVehicleAttrWithId(variableId: 29)
                
                print("Make: \(self.currVehicleInfo!["make"]!)")
                print("Model: \(self.currVehicleInfo!["model"]!)")
                print("Model Year: \(self.currVehicleInfo!["year"]!)")
                
                NotificationCenter.default.post(name: self.newVehicleInfoNotification, object: nil)
                
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
                let user_values = ["vehicle_user_mileage": 0]
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
                self.ref.child("userVehicles/\(uid!)").updateChildValues(["user_mileage": 0.0, "trips": 0])
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
    
    func writeTrip(ts: Int, miles: Double, vin: String) {
        userTripCount! += 1
        
        let uid = FIRAuth.auth()?.currentUser?.uid
        let key = self.ref.child("vehicles").childByAutoId().key
        let values = ["timestamp": ts, "mileage": miles] as [String : Any]
        let updates = ["vehicles/\(vin)/users/\(uid!)/trips/\(key)": values]
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
        ref.child("userVehicles/\(uid!)").observeSingleEvent(of: .value, with: { (snapshot) in
            let user_obj = snapshot.value as! [String: Any]
            self.ref.child("userVehicles/\(uid!)/user_mileage").setValue((user_obj["user_mileage"] as! Double) + miles)
            self.ref.child("userVehicles/\(uid!)/trips").setValue((user_obj["trips"] as! Int) + 1)
        })
    }
    
}

