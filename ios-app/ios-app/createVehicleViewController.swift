//
//  createVehicleViewController.swift
//  ios-app
//
//  Created by Jack Fox on 5/16/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseDatabase


class createVehicleViewController: UIViewController {

    // Outlets
    @IBOutlet weak var brandOBD: UILabel!
    @IBOutlet weak var modelOBD: UILabel!
    @IBOutlet weak var yearOBD: UILabel!
    @IBOutlet weak var vinOBD: UILabel!
    @IBOutlet weak var nicknameTextInput: UITextField!
    
    
    var ref: FIRDatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()

    }

    func getVehicle() {
        
    }
    
    func registerVehicle() {
    
    }
    
    
    @IBAction func submittTapped(_ sender: UIButton) {
        registerVehicle()
    }
}
