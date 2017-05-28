//
//  signInContainerViewController.swift
//  ios-app
//
//  Created by ishansaksena on 5/20/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit
import FirebaseAuth
import Eureka

class signInContainerViewController: UIViewController {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    var formViewController: signInFormViewController!
    
    let loginErrorAlert = UIAlertController(title: "Error", message: "That email & password combination is not valid!", preferredStyle: UIAlertControllerStyle.alert)
    let emailErrorAlert = UIAlertController(title: "Error", message: "Not a valid email", preferredStyle: UIAlertControllerStyle.alert)
    let passwordErrorAlert = UIAlertController(title: "Error", message: "Not a valid password", preferredStyle: UIAlertControllerStyle.alert)
    
    let passwordResetAlert = UIAlertController(title: "Reset Password", message: "Please enter your account email:", preferredStyle: .alert)
    let passwordResetConfirmationAlert = UIAlertController(title: "Reset Password", message: "", preferredStyle: .alert)
    let passwordResetErrorAlert = UIAlertController(title: "Error", message: "Error: email does not match a valid WARUC account.", preferredStyle: .alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = Colors.green
        nextButton.layer.cornerRadius = CGFloat(Constants.round)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) in
            
        })
        
        let okResetAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction!) in
            self.performSegue(withIdentifier: "returnToVideo", sender: nil)
        })
        
        loginErrorAlert.addAction(okAction)
        emailErrorAlert.addAction(okAction)
        passwordErrorAlert.addAction(okAction)
        passwordResetConfirmationAlert.addAction(okResetAction)
        passwordResetErrorAlert.addAction(okAction)
        
        passwordResetAlert.addAction(UIAlertAction(title: "Reset", style: .default, handler: {
            alert -> Void in
            let email = self.passwordResetAlert.textFields![0] as UITextField
            
            FIRAuth.auth()?.sendPasswordReset(withEmail: email.text ?? "") { error in
                if error == nil {
                    self.passwordResetConfirmationAlert.message = "Password reset email sent to \(email.text!)"
                    self.dismiss(animated: true, completion: nil)
                    self.present(self.passwordResetConfirmationAlert, animated: true, completion: nil)
                    
                } else {
                    self.dismiss(animated: true, completion: nil)
                    self.present(self.passwordResetErrorAlert, animated: true, completion: {
                        self.present(self.passwordResetAlert, animated: true, completion: nil)
                    })
                }
            }
        }))
        
        passwordResetAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        passwordResetAlert.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
            textField.placeholder = "Email"
        })
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
            self.login(form: vc.form)
        }
    }

    // Attempt firbase login 
    func login(form: Form) {
        let values = form.values()
        if values["email"]! == nil || values["pass"]! == nil {
            self.present(self.emailErrorAlert, animated: true, completion: nil)
        } else {
            let rows = form.sectionBy(tag: "account")
            let email = values["email"] as! String
            let pass = values["pass"] as! String
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
            if !((rows?[1].isValid)!) || (pass == "") {
                valid = false
                self.present(self.passwordErrorAlert, animated: true, completion: nil)
                print("Invalid Password")
            } else {
                print("Password is valid")
            }
            
            if valid {
                //let user = FIRAuth.auth()?.currentUser
                FIRAuth.auth()?.signIn(withEmail: email, password: pass, completion: { (user, error) in
                    if user != nil {
                        //if !(user?.isEmailVerified)! {
                        DB.sharedInstance.getUserData()
                        NotificationCenter.default.addObserver(self,
                                                               selector: #selector(self.startBLEScan),
                                                               name: BLERouter.sharedInstance.sharedInstanceReadyNotification,
                                                               object: nil)
                        
                        self.performSegue(withIdentifier: "authorized", sender: self)
                    } else {
                        print("Sign In Error")
                        self.present(self.loginErrorAlert, animated: true, completion: nil)
                    }
                })
            }
        }
    }
    
    func startBLEScan() {
        BLERouter.sharedInstance.centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    @IBAction func resetPassword(_ sender: Any) {
        present(passwordResetAlert, animated: true, completion: nil)
    }
    
}
