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

class signInViewController: UIViewController, UITextFieldDelegate {

    // Outlets
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    
    // Class Variables
    var ref: FIRDatabaseReference!
    
    let loginErrorAlert = UIAlertController(title: "Error", message: "That email & password combination is not valid!", preferredStyle: UIAlertControllerStyle.alert)
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.passwordText.delegate = self
        self.logInButton.layer.cornerRadius = 10
        
        ref = FIRDatabase.database().reference()
        //getUserJSON()
        
        loginErrorAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            //print("Handle Ok logic here")
        }))
    }
    
    @IBAction func logInButtonTouched(_ sender: UIButton) {
        login()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        passwordText.resignFirstResponder()
        login()
        return true
    }
    d
    func login() {
        if let email = emailText.text, let pass = passwordText.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: pass, completion: { (user, error) in
                if user != nil {
                    self.performSegue(withIdentifier: "authenticationComplete", sender: self)
                } else {
                    print("Sign In Error")
                    self.present(self.loginErrorAlert, animated: true, completion: nil)
                }
                
            })
        }
    }
    
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
    
    
    func getUserJSON() {
        let uid = FIRAuth.auth()?.currentUser?.uid //function argument
        let dummy_keys: [String] = ["0", "1", "2"] // will call getUserVechiles()
        
        for key in dummy_keys {
            ref!.child("vehicles/" + key + "/users/" + uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                let user_json = JSON(snapshot.value!)
                print(user_json)
            }, withCancel: nil)
            
            ref!.child("vehicles/" + key).observeSingleEvent(of: .value, with: { (snapshot) in
                var vehicle_json = JSON(snapshot.value!)
                vehicle_json.dictionaryObject?.removeValue(forKey: "users")
                print(vehicle_json)
            }, withCancel: nil)
        }
    }
}
