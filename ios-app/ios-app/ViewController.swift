//
//  ViewController.swift
//  ios-app
//
//  Created by Nicholas Nordale on 4/1/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit
import FirebaseAuth



class ViewController: UIViewController {
    
    @IBOutlet weak var signinSelector: UISegmentedControl!
    
    @IBOutlet weak var signInLabel: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    var isSignIn:Bool = true

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func signInSelectorChanged(_ sender: UISegmentedControl) {
        
        isSignIn = !isSignIn
        
        //Check the bool and set the button and labels
        if isSignIn {
            signInLabel.text = "Sign In"
            signInButton.setTitle("Sign In", for: .normal)
        }
        else {
            signInLabel.text = "Create an Account"
            signInButton.setTitle("Create an Account", for: .normal)
        }
    }
    
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        // TODO: Form validation
        
        if let email = emailTextField.text, let pass = passwordTextField.text {
            // check if sign in or create a new account
            if isSignIn {
                // Sign in with Firebase
                FIRAuth.auth()?.signIn(withEmail: email, password: pass, completion: { (user, error) in
                    
                    //check that user is not nill
                    if let u = user {
                        // User is found
                        self.performSegue(withIdentifier: "goToSuccess", sender: self)
                    }
                    else {
                        
                    }
                    
                })

                
            }
            else {
                // Register the user with Firebase
                FIRAuth.auth()?.createUser(withEmail: email, password: pass, completion: { (user, error) in
                    if let u = user {
                        // User is found
                        self.performSegue(withIdentifier: "goToSuccess", sender: self)
                    }
                    else {
                        // display error
                    }
                })
            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Dismiss the keyboard when the view is tapped on
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
}

