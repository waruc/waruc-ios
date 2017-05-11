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
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    var ref: FIRDatabaseReference!
    var isSignIn:Bool = true
    
    // On app load
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
//        getUserVechiles()
//        getUserProfile()
//        trobuleShoot()
        troubleV2()
    }
    


    @IBAction func backButtonTapped(_ sender: UIButton) {
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
                        self.performSegue(withIdentifier: "goToSuccess", sender: self)
                    }
                    else {
                        print("Troubles in Paradise")
                    }
                    
                })

                
            }
            else {
                // Register the user with Firebase
                FIRAuth.auth()?.createUser(withEmail: email, password: pass, completion: { (user, error) in
                    if let u = user {
                        // User is found
                        self.performSegue(withIdentifier: "goToSuccess", sender: self)
                    }
                    else {
                        // display error
                        print("You done fucked up")
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


    // Remove on iPhone keyboard. Quality of life dev tool
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
    
    func getUserProfile() {
        if FIRAuth.auth()?.currentUser?.uid != nil {
            let uid = FIRAuth.auth()?.currentUser?.uid
            ref.child("vehicles/0/users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
//                print(snapshot.value)
                let dic = snapshot.value as? [String: AnyObject]
                let values = dic!["devices"] as? NSArray
                print(values!)
//                print(dic!)
//                print(values!.value)
                
            }, withCancel: nil)
            
        }
    }
    
    func trobuleShoot() {
        if FIRAuth.auth()?.currentUser?.uid != nil {
            let uid = FIRAuth.auth()?.currentUser?.uid
            ref.child("vehicles").observeSingleEvent(of: .value, with: { (snapshot) in
               let enumerator = snapshot.children
                while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                    if rest.hasChild("users/" + uid!) {
                        let child_snap = rest.childSnapshot(forPath: "users/" + uid!)
                    }
                }
                
            }, withCancel: nil)
            
        }
    }
    
    func troubleV2() {
        let uid = FIRAuth.auth()?.currentUser?.uid //function argument
        let dummy_keys: [String] = ["0", "1", "2"] // will call getUserVechiles()

        for key in dummy_keys {
            ref.child("vehicles/" + key + "/users/" + uid!).observeSingleEvent(of: .value, with: { (snapshot) in
//                print(snapshot.ref)
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






//                let vechile_dic = snapshot.value as? [String: AnyObject]
//                print(vechile_dic?.values)

// return value and priority
//                let export = snapshot.valueInExportFormat()
//                print(export)
//                let json = JSON(snapshot.value) as? [String: AnyObject]
//                print(json)
//let enumerator = snapshot.children
//while let rest = enumerator.nextObject() as? FIRDataSnapshot {}



