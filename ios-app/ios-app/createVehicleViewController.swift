//
//  createVehicleViewController.swift
//  ios-app
//
//  Created by Jack Fox on 5/16/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth

class createVehicleViewController: UIViewController {

    // Outlets
    @IBOutlet weak var brandOBD: UILabel!
    @IBOutlet weak var modelOBD: UILabel!
    @IBOutlet weak var yearOBD: UILabel!
    @IBOutlet weak var vinOBD: UILabel!
    @IBOutlet weak var nicknameTextInput: UITextField!
    
    
    var ref: FIRDatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()

    }
    
    func registerVehicle(vin: String, make: String, model: String, year: String) {
        let uid = FIRAuth.auth()?.currentUser?.uid
        let key = self.ref.child("vehicles").childByAutoId().key
        
        let vehicle_values = [
            "brand" : make,
            "model": model,
            "year": year,
            "users": uid!,
            "vin": vin,
            "nickname": nicknameTextInput.text!,
            "startDatetime": FIRServerValue.timestamp()
            ] as [String : Any]
        
        let user_values = [
            "trips": ["placeholder": "na"],
            "total_mileage": 0,
            
            ] as [String : Any]
        
        ref.child("vehicles").updateChildValues([key : vehicle_values])
        ref.child("vehicles/" + key + "/users").updateChildValues([uid! : user_values])
        updateUserVehicles(key: key, uid: uid!)
        
    }
    
    func updateUserVehicles(key: String, uid: String) {
        ref.child("userVehicles/" + uid + "/vehicles").updateChildValues([key: "owner"])
        
        // Remove an placeholder values that are created during the user onboarding process
        ref.child("userVehicles/" + uid + "/vehicles").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild("placeholder"){
                self.ref.child("userVehicles/" + uid + "/vehicles/placeholder").removeValue()
            }
        }, withCancel: nil)
    }
    
    @IBAction func submittTapped(_ sender: UIButton) {
        registerVehicle(vin: "123456", make: "Ford", model: "F150", year: "1996")
    }
}
