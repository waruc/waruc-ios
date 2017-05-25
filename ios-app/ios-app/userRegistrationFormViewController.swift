//
//  userRegistrationFormViewController.swift
//  ios-app
//
//  Created by ishansaksena on 5/18/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit
import Eureka

class userRegistrationFormViewController: FormViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section(header: "Sign Up", footer: "Passwords must contain at least 8 characters") { section in
                section.tag = "account"
            }
            
            <<< EmailRow() {
                $0.title = "Email"
                $0.tag = "email"
                $0.add(rule: RuleRequired())
                var ruleSet = RuleSet<String>()
                ruleSet.add(rule: RuleRequired())
                ruleSet.add(rule: RuleEmail())
                $0.add(ruleSet: ruleSet)
                $0.validationOptions = .validatesOnChangeAfterBlurred
                $0.placeholder = "example@email.com"
                }
                .cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
            }
            
            <<< PasswordRow() {
                $0.title = "Password"
                $0.tag = "pass1"
                $0.add(rule: RuleMinLength(minLength: 8))
                }
                .cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
            }
            
            <<< PasswordRow() {
                $0.title = "Retype Password"
                $0.tag = "pass2"
                $0.add(rule: RuleMinLength(minLength: 8))
                }
                .cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
            }
    }
}
