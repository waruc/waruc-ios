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

class signInViewController: UIViewController {

    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
}
