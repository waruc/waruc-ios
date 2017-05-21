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

class OnboardingAccountDetailsViewController: UIViewController {
    
    @IBOutlet weak var nextButton: UIButton!
    
    var formViewController: userRegistrationFormViewController!
    let passwordErrorAlert = UIAlertController(title: "Error", message: "Passwords do not match!", preferredStyle: UIAlertControllerStyle.alert)
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.nextButton.layer.cornerRadius = CGFloat(Constants.round)
        nextButton.clipsToBounds = true
        self.navigationController?.navigationBar.tintColor = Colors.green
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
            let values = vc.form.values()
            self.createUser(values: values)
        }
    }
    
    func createUser(values: [String: Any?]) {
        let password = values["pass1"] as! String
        let password_verify = values["pass2"] as! String
        let email = values["email"] as! String
        
        if password == password_verify {
            FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                let uid = FIRAuth.auth()?.currentUser?.uid
                let values = ["total_miles": 0, "name": email] as [String : Any]
                if uid != nil {
                    DB.sharedInstance.ref.child("userVehicles/").updateChildValues([String(uid!): values])
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
