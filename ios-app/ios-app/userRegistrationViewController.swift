//
//  userRegistrationViewController.swift
//  ios-app
//
//  Created by iGuest on 5/5/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit

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
        
        

        // Do any additional setup after loading the view.
    }

    @IBAction func next(_ sender: UIButton) {
    }
    
}
