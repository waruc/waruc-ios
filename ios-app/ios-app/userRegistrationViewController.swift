//
//  userRegistrationViewController.swift
//  ios-app
//
//  Created by iGuest on 5/5/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class userRegistrationViewController: UIViewController, UITextFieldDelegate {

    //Labels
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordRepeatLabel: UILabel!
    
    //Fields
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordRepeatField: UITextField!
    
    @IBOutlet weak var createAccountButton: UIButton!
    
    var ref: FIRDatabaseReference!
    
    let passwordErrorAlert = UIAlertController(title: "Error", message: "Passwords do not match!", preferredStyle: UIAlertControllerStyle.alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.passwordRepeatField.delegate = self
        self.createAccountButton.layer.cornerRadius = 10
        
        ref = FIRDatabase.database().reference()
        
        passwordErrorAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            //print("Handle Ok logic here")
        }))
    }
    @IBAction func cheat(_ sender: UIButton) {
        self.performSegue(withIdentifier: "accountCreatedSuccessfully", sender: self)
    }
    
    @IBAction func createAccountButtonTouched(_ sender: UIButton) {
        createUser()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        passwordRepeatField.resignFirstResponder()
        createUser()
        return true
    }

    func createUser() {
        let password = passwordField.text!
        let password_verify = passwordRepeatField.text!
        let email = emailField.text!
        
        if password == password_verify {
            FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                let uid = FIRAuth.auth()?.currentUser?.uid
                if uid != nil {
                    //Create the user in the database
                    let values = ["OTHER_INFO": "placeholder", "name": "placeholder", "vehicles": ["placeholder": "na"]] as [String : Any]
                    self.ref.child("userVehicles/").updateChildValues([String(uid!): values])
                    self.performSegue(withIdentifier: "accountCreatedSuccessfully", sender: self)
                } else {
                    print("Create User error")
                }
            })
        } else {
            present(passwordErrorAlert, animated: true, completion: nil)
        }
        
    }
}
