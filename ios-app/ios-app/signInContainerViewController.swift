//
//  signInContainerViewController.swift
//  ios-app
//
//  Created by ishansaksena on 5/20/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit
import FirebaseAuth

class signInContainerViewController: UIViewController {

    var formViewController: userRegistrationFormViewController!
    let loginErrorAlert = UIAlertController(title: "Error", message: "That email & password combination is not valid!", preferredStyle: UIAlertControllerStyle.alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userRegistration" {
            let connectContainerViewController = segue.destination as! userRegistrationFormViewController
            formViewController = connectContainerViewController
        }
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        if let vc = formViewController {
            let values = vc.form.values()
            self.login(values: values)
        }
    }

    
    func login(values: [String: Any?]) {
        let email = values["email"] as! String
        let pass = values["pass"] as! String
        FIRAuth.auth()?.signIn(withEmail: email, password: pass, completion: { (user, error) in
            if user != nil {
                self.performSegue(withIdentifier: "authorized", sender: self)
            } else {
                print("Sign In Error")
                self.present(self.loginErrorAlert, animated: true, completion: nil)
            }
        })
    }
}
