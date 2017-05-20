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
    
    let passwordErrorAlert = UIAlertController(title: "Error", message: "Passwords do not match!", preferredStyle: UIAlertControllerStyle.alert)
    
    var ref: FIRDatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        self.passwordRepeatField.delegate = self
        self.createAccountButton.layer.cornerRadius = 10
        
        passwordErrorAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            //print("Handle Ok logic here")
        }))
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
                let values = ["total_miles": 0, "name": email] as [String : Any]
                if uid != nil {
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
