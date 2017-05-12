//
//  signInViewController.swift
//  ios-app
//
//  Created by Jack Fox on 5/11/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import SwiftyJSON


class signInViewController: UIViewController {

    // Outlets
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    
    // Class Variables
    var ref: FIRDatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        getUserJSON()

    }

    @IBAction func logInButtonTouched(_ sender: UIButton) {
        if let email = emailText.text, let pass = passwordText.text {
            // Sign in with Firebase
            FIRAuth.auth()?.signIn(withEmail: email, password: pass, completion: { (user, error) in
                //check that user is not nill
                if let u = user {
                    // User is found
                    self.performSegue(withIdentifier: "goToSuccess", sender: self)
                    }
                    else {
                        print("Error in Sign In")
                    }
                    
                })
        }
    }
    
    func getUserVehicles() -> Array<Any> {
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
            print("Error fetching user vehicles")
        }
        return []
    }
    
    
    func getUserJSON() {
        let uid = FIRAuth.auth()?.currentUser?.uid //function argument
        let dummy_keys: [String] = ["0", "1", "2"] // will call getUserVechiles()
        
        for key in dummy_keys {
            ref.child("vehicles/" + key + "/users/" + uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                let user_json = JSON(snapshot.value)
                print(user_json)
            }, withCancel: nil)
            
            ref.child("vehicles/" + key).observeSingleEvent(of: .value, with: { (snapshot) in
                var vehicle_json = JSON(snapshot.value)
                vehicle_json.dictionaryObject?.removeValue(forKey: "users")
                print(vehicle_json)
            }, withCancel: nil)
        }
    }
    
    
    
    
}
