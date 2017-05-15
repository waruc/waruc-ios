//
//  VehicleRegistrationViewController.swift
//  ios-app
//
//  Created by Babbs, Dylan on 5/5/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseDatabase

class VehicleRegistrationViewController: UIViewController {
    
    //Labels
    @IBOutlet weak var brandOBD: UILabel!
    @IBOutlet weak var modelOBD: UILabel!
    @IBOutlet weak var yearOBD: UILabel!
    @IBOutlet weak var vinOBD: UILabel!
    
    //Fields
    @IBOutlet weak var vehicleNicknameField: UITextField!

    var ref: FIRDatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
    }
    
    // Grab Vehicle info from OBD
    func getVehicleInfo () {
        
    }
    
    func registerVehicle() {
        getVehicleInfo()
//        let dummmy_var = ["Ford", "F150", "1992", "123456"]
    }
    
    
    @IBAction func next(_ sender: UIButton) {
        registerVehicle()
    }
    
    @IBAction func later(_ sender: UIButton) {
    }


}
