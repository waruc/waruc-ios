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

class userRegistrationViewController: UIViewController {

    //Labels
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordRepeatLabel: UILabel!
    
    //Fields
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordRepeatField: UITextField!
    
    
    var ref: FIRDatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
    }

    func createUser() {
        let password = passwordField.text
        let password_verify = passwordRepeatField.text
        let email = emailField.text
        
        if password == password_verify {
            FIRAuth.auth()?.createUser(withEmail: email!, password: password!, completion: { (user, error) in
                let uid = FIRAuth.auth()?.currentUser?.uid
                if uid != nil {
                    //Create the user in the database
                    let values = ["OTHER_INFO": "placeholder", "name": "placeholder", "vehicles": ["placeholder": "na"]] as [String : Any]
                    self.ref.child("userVehicles/").updateChildValues([String(uid!): values])
                    self.performSegue(withIdentifier: "goToSignUp", sender: self)
                } else {
                    print("Create User error")
                }
            })
        }
        
    }
    
    @IBAction func next(_ sender: UIButton) {
        createUser()
    }
    
}
