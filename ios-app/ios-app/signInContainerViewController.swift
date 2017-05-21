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

    @IBOutlet weak var nextButton: UIButton!
    var formViewController: signInFormViewController!
    
    let loginErrorAlert = UIAlertController(title: "Error", message: "That email & password combination is not valid!", preferredStyle: UIAlertControllerStyle.alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = Colors.green
        nextButton.layer.cornerRadius = CGFloat(Constants.round)
    }
    
    // Get a reference to the embedded view controller for the form
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userSignIn" {
            let connectContainerViewController = segue.destination as! signInFormViewController
            formViewController = connectContainerViewController
        }
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        if let vc = formViewController {
            let values = vc.form.values()
            self.login(values: values)
        }
    }

    // Attempt firbase login 
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
