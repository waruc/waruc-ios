//
//  initialViewController.swift
//  ios-app
//
//  Created by iGuest on 5/5/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit

class initialViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func login(_ sender: UIButton) {
        //self.performSegue(withIdentifier: "startGame", sender: self)
    }

    @IBAction func signUp(_ sender: UIButton) {
    }
}
