//
//  createVehicleViewController.swift
//  ios-app
//
//  Created by Jack Fox on 5/16/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit

class createVehicleViewController: UIViewController, UITextFieldDelegate {

    // Outlets
    @IBOutlet weak var makeOBD: UILabel!
    @IBOutlet weak var modelOBD: UILabel!
    @IBOutlet weak var yearOBD: UILabel!
    @IBOutlet weak var nicknameTextInput: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        submitButton.isEnabled = false
        nicknameTextInput.isEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nicknameTextInput.delegate = self

//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(self.displayVehicleInfo),
//                                               name: DB.sharedInstance.vehicleInfoNotification,
//                                               object: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nicknameTextInput.resignFirstResponder()
        createVehicle()
        return true
    }
    
    @IBAction func submittTapped(_ sender: UIButton) {
        createVehicle()
    }
    
    func displayVehicleInfo() {
        makeOBD.text = DB.sharedInstance.currVehicleInfo!["make"]!
        modelOBD.text = DB.sharedInstance.currVehicleInfo!["model"]!
        yearOBD.text = DB.sharedInstance.currVehicleInfo!["year"]!
        submitButton.isEnabled = true
        nicknameTextInput.isEnabled = true
    }
    
    func createVehicle() {
//        DB.sharedInstance.registerVehicle(vin: BLERouter.sharedInstance.vinNumber!,
//                                          make: makeOBD.text!,
//                                          model: modelOBD.text!,
//                                          year: yearOBD.text!,
//                                          nickname: nicknameTextInput.text)
    }
}
