//
//  signInViewController.swift
//  ios-app
//
//  Created by Jack Fox on 5/11/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit
import FirebaseAuth

class signInViewController: UIViewController, UITextFieldDelegate {

    // Outlets
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    
    let loginErrorAlert = UIAlertController(title: "Error", message: "That email & password combination is not valid!", preferredStyle: UIAlertControllerStyle.alert)
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.passwordText.delegate = self
        self.logInButton.layer.cornerRadius = 10
        
        loginErrorAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            //print("Handle Ok logic here")
        }))
    }
    
    @IBAction func logInButtonTouched(_ sender: UIButton) {
        login()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        passwordText.resignFirstResponder()
        login()
        return true
    }
    
    func login() {
        if let email = emailText.text, let pass = passwordText.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: pass, completion: { (user, error) in
                if user != nil {
                    self.performSegue(withIdentifier: "authenticationComplete", sender: self)
                } else {
                    print("Sign In Error")
                    self.present(self.loginErrorAlert, animated: true, completion: nil)
                }
            })
        }
    }
}
