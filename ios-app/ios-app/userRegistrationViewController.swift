//
//  userRegistrationViewController.swift
//  ios-app
//
//  Created by iGuest on 5/5/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit
import FirebaseAuth

class userRegistrationViewController: UIViewController {

    //Labels
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordRepeatLabel: UILabel!
    
    //Fields
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordRepeatField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func next(_ sender: UIButton) {
        if let email = emailField.text, let pass = passwordField.text{
            FIRAuth.auth()?.createUser(withEmail: email, password: pass, completion: { (user, error) in
                if let u = user {
                    self.performSegue(withIdentifier: "goToSignUp", sender: self)
                }
                else {
                    print("Create User Error")
                }
            })
        }
    }
    
}
