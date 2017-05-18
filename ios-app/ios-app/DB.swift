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
    var vinData:[JSON] = []
    var currVehicleInfo:[String : String] = [
        "make": "",
        "model": "",
        "year": "",
        "nickname": ""
    ]
    
    init() {
        self.ref = FIRDatabase.database().reference()
        self.feedRad = 5500
        self.refreshFeed = false
    }
    
    static let sharedInstance = DB()
    
    func getUserVehicles() -> Array<Any> {
        if FIRAuth.auth()?.currentUser?.uid != nil {
            // fetch data from Firebase
            let uid = FIRAuth.auth()?.currentUser?.uid
            ref!.child("userVehicles").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                var vehicle_keys = [String]()
                let enumerator = snapshot.children
                while let rest = enumerator.nextObject() as? FIRDataSnapshot{
                    vehicle_keys.append(rest.key)
                }
                print(vehicle_keys)
            }, withCancel: nil)
        } else {
            print("Error fetching user vehicles")
        }
        return []
    }
    
    func addPlaceholderToUserVehicles() {
        //Create the user in the database
        let uid = FIRAuth.auth()?.currentUser?.uid
        let values = ["OTHER_INFO": "placeholder", "name": "placeholder", "vehicles": ["placeholder": "na"]] as [String : Any]
        self.ref.child("userVehicles/").updateChildValues([uid!: values])
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
        
        let user_values = ["trips": [], "total_mileage": 0] as [String : Any]
        
        ref.child("vehicles").updateChildValues([vin : vehicle_values])
        ref.child("vehicles/\(vin)/users").updateChildValues([uid! : user_values])
        updateUserVehicles(key: vin, uid: uid!)
    }
    
    func updateUserVehicles(key: String, uid: String) {
        ref.child("userVehicles/\(uid)/vehicles").updateChildValues([key: "owner"])
        
        // Remove an placeholder values that are created during the user onboarding process
        ref.child("userVehicles/\(uid)/vehicles").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild("placeholder"){
                self.ref.child("userVehicles/\(uid)/vehicles/placeholder").removeValue()
            }
        }, withCancel: nil)
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
                        self.currVehicleInfo["nickname"] = "Nick's Car"
                        
                        self.registerVehicle(vin: vin,
                                             make: self.currVehicleInfo["make"]!,
                                             model: self.currVehicleInfo["model"]!,
                                             year: self.currVehicleInfo["year"]!,
                                             nickname: self.currVehicleInfo["nickname"])
                        
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
    
    func vinLookupUrl(vin: String) -> String {
        return "https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVin/\(vin)*BA?format=json"
    }
    
    func getVehicleAttrWithId(variableId: Int) -> String {
        return vinData.filter { $0["VariableId"].intValue == variableId }[0]["Value"].stringValue
    }
}

