//
//  OnboardingAccountDetailsViewController.swift
//  ios-app
//
//  Created by Babbs, Dylan on 5/20/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import Eureka

class OnboardingAccountDetailsViewController: UIViewController {
    
    @IBOutlet weak var nextButton: UIButton!
    
    var formViewController: userRegistrationFormViewController!
    var ref: FIRDatabaseReference!
    
    // Login error alerts
    let loginErrorAlert = UIAlertController(title: "Error", message: "That email & password combination is not valid!", preferredStyle: UIAlertControllerStyle.alert)
    let emailErrorAlert = UIAlertController(title: "Error", message: "Not a valid email", preferredStyle: UIAlertControllerStyle.alert)
    let passwordErrorAlert = UIAlertController(title: "Error", message: "Not a valid password", preferredStyle: UIAlertControllerStyle.alert)
    let passwordMatchErrorAlert = UIAlertController(title: "Error", message: "Passwords do not match!", preferredStyle: UIAlertControllerStyle.alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.nextButton.layer.cornerRadius = CGFloat(Constants.round)
        nextButton.clipsToBounds = true
        self.navigationController?.navigationBar.tintColor = Colors.green
        
        // Alerts
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) in })
        loginErrorAlert.addAction(okAction)
        emailErrorAlert.addAction(okAction)
        passwordErrorAlert.addAction(okAction)
        passwordMatchErrorAlert.addAction(okAction)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
        
        
        if segue.identifier == "userRegistration" {
            let connectContainerViewController = segue.destination as! userRegistrationFormViewController
            formViewController = connectContainerViewController
        }
    }

    @IBAction func nextButtonPressed(_ sender: Any) {
        if let vc = formViewController {
            self.createUser(form: vc.form)
        }
    }
    
    func createUser(form: Form) {
        let values = form.values()
        let rows = form.sectionBy(tag: "account")
        let email = values["email"] as! String
        let password = values["pass1"] as! String
        let password_verify = values["pass2"] as! String
        var valid = true
        
        // Email
        // Not valid or empty
        if !((rows?[0].isValid)!) || (email == "") {
            valid = false
            self.present(self.emailErrorAlert, animated: true, completion: nil)
            print("Invalid email")
        } else {
            print("Email is valid")
        }
        
        // Password
        // Not valid or empty
        if !((rows?[1].isValid)!) || !((rows?[1].isValid)!) || (password == "") || (password_verify == "") {
            valid = false
            self.present(self.passwordErrorAlert, animated: true, completion: nil)
            print("Invalid Password")
        } else {
            print("Password is valid")
        }
        
        if password != password_verify {
            valid = false
            present(passwordMatchErrorAlert, animated: true, completion: nil)
            print("passwords don't match")
        }
        
        if valid {
            FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                let uid = FIRAuth.auth()?.currentUser?.uid
                let values = ["trips": 0, "user_mileage": 0.0, "name": email] as [String : Any]
                if uid != nil {
                    DB.sharedInstance.ref.child("userVehicles/").updateChildValues([String(uid!): values])
                    self.performSegue(withIdentifier: "accountCreatedSuccessfully", sender: self)
                } else {
                    self.present(self.loginErrorAlert, animated: true, completion: nil)
                    print("Create User error")
                }
            })
        }
    }
}
