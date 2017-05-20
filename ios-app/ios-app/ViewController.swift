//
//  ViewController.swift
//  ios-app
//
//  Created by Nicholas Nordale on 4/1/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SwiftyJSON


class ViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var signinSelector: UISegmentedControl!
    @IBOutlet weak var signInLabel: UILabel!
    
    // Outlet Textfields
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var brandTextField: UITextField!
    @IBOutlet weak var modelTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    
    // Outlet buttons
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    var ref: FIRDatabaseReference!
    var isSignIn:Bool = true
    
    // On app load
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        let date = Date()
        let ts = Int(date.timeIntervalSince1970.rounded())
        
        
        
        
        //        getUserVechiles()
        writeTrip(ts: ts, miles: 53.6912, vin: "1G1JC5444R7252367", uid: "eE3ArfvjeoOcpijMEqLVHaI0lOG2")
//        getTrips(vin:"1G1JC5444R7252367", uid: "eE3ArfvjeoOcpijMEqLVHaI0lOG2")
//        if FIRAuth.auth()?.currentUser?.uid != nil {
//            getUserData()
//        }
    }
    


    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "returnHome", sender: self)
    }
    
    @IBAction func signInSelectorChanged(_ sender: UISegmentedControl) {
    
        isSignIn = !isSignIn
        //Check the bool and set the button and labels
        if isSignIn {
            signInLabel.text = "Sign In"
            signInButton.setTitle("Sign In", for: .normal)
        }
        else {
            signInLabel.text = "Create an Account"
            signInButton.setTitle("Create an Account", for: .normal)
        }
    }
    
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        // TODO: Form validation
        
        if let email = emailTextField.text, let pass = passwordTextField.text {
            // check if sign in or create a new account
            if isSignIn {
                // Sign in with Firebase
                FIRAuth.auth()?.signIn(withEmail: email, password: pass, completion: { (user, error) in
                    //check that user is not nill
                    if let u = user {
                        // User is found
                        print("S--s-s-egue")
                        self.performSegue(withIdentifier: "goToSuccess", sender: self)
                    }
                    else {
                        print("No user Sign In")
                    }
                    
                })

                
            }
            else {
                // Register the user with Firebase
                FIRAuth.auth()?.createUser(withEmail: email, password: pass, completion: { (user, error) in
                    let uid = FIRAuth.auth()?.currentUser?.uid
                    
                    //
                    if uid != nil {
                        let values = ["OTHER_INFO": "placeholder", "name": "placeholder", "vehicles": ["placeholder": "na"]] as [String : Any]
                        self.ref.child("userVehicles/").updateChildValues([String(uid!): values])
                        self.performSegue(withIdentifier: "goToSuccess", sender: self)
                    }
                    else {
                        // display error
                        print("No Create User")
                    }
                })
            }
        }
        
    }
    
    // Logout User
    @IBAction func logOutUser(_ sender: Any) {
        do {
            try FIRAuth.auth()?.signOut()
            self.performSegue(withIdentifier: "returnHome", sender: self)
        } catch let logoutError {
            print (logoutError)
        }
    }
    
    
    @IBAction func submittButtonTapped(_ sender: UIButton) {
        createVehicle_v2(vin: "123456", make: "Ford", model: "F150", year: "1996")
    }


    // Remove on iPhone keyboard. Quality of life dev function
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Dismiss the keyboard when the view is tapped on
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    // retrieve user vehcile data on login
    func getUserVechiles() -> Array<Any> {
        if FIRAuth.auth()?.currentUser?.uid != nil {
            // fetch data from Firebase
            let uid = FIRAuth.auth()?.currentUser?.uid
            ref.child("userVehicles").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                var vhecile_keys = [String]()
                let enumerator = snapshot.children
                while let rest = enumerator.nextObject() as? FIRDataSnapshot{
                    vhecile_keys.append(rest.key)
                }
                print(vhecile_keys)
            }, withCancel: nil)
        } else {
            logOutUser(self)
        }
        return []
    }
    
    func getUserData() { //need to ensure that a uID is not null and is in the databaes
        let uid = FIRAuth.auth()?.currentUser?.uid //function argument
        let dummy_keys: [String] = ["0", "1", "2"] // will call getUserVechiles()

        for key in dummy_keys {
            ref.child("vehicles/" + key + "/users/" + uid!).observeSingleEvent(of: .value, with: { (snapshot) in
//                print(snapshot.ref)
                let user_json = JSON(snapshot.value)
//                print(user_json)
            }, withCancel: nil)
            
            ref.child("vehicles/" + key).observeSingleEvent(of: .value, with: { (snapshot) in
                var vehicle_json = JSON(snapshot.value)
                vehicle_json.dictionaryObject?.removeValue(forKey: "users")
//                print(vehicle_json)
            }, withCancel: nil)
        }
    }
    
    func createVehicle() {
        if FIRAuth.auth()?.currentUser?.uid != nil {
            let uid = FIRAuth.auth()?.currentUser?.uid
    
            let brand = brandTextField.text
            let model = modelTextField.text
            let year = yearTextField.text  //need to preform forum validation
            
            let model_count = model!.characters.count
            let brand_count = brand!.characters.count
            let year_count = year!.characters.count
            
        
            if model_count > 0, brand_count > 0, year_count > 0{
                // Read and Update index_vechile
                ref.child("index_vehicle").observeSingleEvent(of: .value, with: { (snapshot) in
                    var total_vehicle = snapshot.value as? Int
                    let new_total = total_vehicle! + 1
                    self.ref.child("index_vehicle").setValue(new_total)
                    self.ref.child("userVehicles/" + uid! + "/vehicles").updateChildValues([String(new_total) : "owner / user"])
                    let new_values = ["brand": brand!, "model": model!, "year" : year!]
                    self.ref.child("vehicles/" + String(new_total)).setValue(new_values)
                    
                }, withCancel: nil)
            }
        }
    }
    
    func createVehicle_v2(vin: String, make: String, model: String, year: String) {
        let uid = FIRAuth.auth()?.currentUser?.uid
        let key = self.ref.child("vehicles").childByAutoId().key
        
        let vehicle_values = [
            "brand" : make,
            "model": model,
            "year": year,
            "users": uid!,
            "vin": vin,
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
        ref.child("userVehicles/" + uid + "/vehicles").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild("placeholder"){
                self.ref.child("userVehicles/" + uid + "/vehicles/placeholder").removeValue()
            }
        }, withCancel: nil)
    }
    
    func getTrips(vin: String, uid: String) {
        ref.child("vehicles/\(vin)/users/\(uid)/trips").observeSingleEvent(of: .value, with: { (snapshot) in
            print("Trips: \(snapshot.value!)")
        }, withCancel: nil)
    }
    
    func writeTrip(ts: Int, miles:Double, vin: String, uid: String) {
        let key = self.ref.child("vehicles").childByAutoId().key
        let values = ["timestamp": ts, "mileage:": miles] as [String : Any]
        let updates = ["vehicles/\(vin)/users/\(uid)/trips/\(key)": values]
        ref.updateChildValues(updates)
        
        
        
        ref.child("userVehicles/\(uid)/total_miles").observeSingleEvent(of: .value, with: { (snapshot) in
            let total_miles = snapshot.value as! Double
            self.ref.child("userVehicles/\(uid)/total_miles").setValue(total_miles + miles)
        }, withCancel: nil)

    }

}






//                let vechile_dic = snapshot.value as? [String: AnyObject]
//                print(vechile_dic?.values)

// return value and priority
//                let export = snapshot.valueInExportFormat()
//                print(export)
//                let json = JSON(snapshot.value) as? [String: AnyObject]
//                print(json)
//let enumerator = snapshot.children
//while let rest = enumerator.nextObject() as? FIRDataSnapshot {}
//let key = self.ref.child("index_vehicle").childByAutoId().key // auto-generates a hash



