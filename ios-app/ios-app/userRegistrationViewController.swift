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

    func createUser() {
        let password = passwordField.text
        let password_verify = passwordRepeatField.text
        let email = emailField.text
        
        if password == password_verify {
            FIRAuth.auth()?.createUser(withEmail: email!, password: password!, completion: { (user, error) in
                let uid = user?.uid != nil
                if uid != nil {
                    //Create the user in the database
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    print(user?.uid)
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
