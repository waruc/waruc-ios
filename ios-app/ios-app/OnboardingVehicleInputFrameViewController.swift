//
//  OnboardingVehicleInputFrameViewController.swift
//  ios-app
//
//  Created by Babbs, Dylan on 5/20/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit

class OnboardingVehicleInputFrameViewController: UIViewController {
    
    var showSkip = false

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.layer.cornerRadius = CGFloat(Constants.round)
        skipButton.layer.cornerRadius = CGFloat(Constants.round)
        
        if DB.sharedInstance.currVehicleInfo == nil {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.modifyButtons),
                                                   name: DB.sharedInstance.newVehicleInfoNotification,
                                                   object: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if DB.sharedInstance.currVehicleInfo == nil {
            if showSkip {
                skipButton.setTitle("Skip", for: .normal)
                skipButton.backgroundColor = doneButton.backgroundColor
            }
            
            doneButton.isHidden = true
        }
    }
    
    @IBAction func vehicleSubmit(_ sender: Any) {
        if DB.sharedInstance.newVehicle {
            DB.sharedInstance.registerVehicle()
        }
        
        DB.sharedInstance.updateVehicleUsers()
        DB.sharedInstance.updateUserVehicles()
        
        //DB.sharedInstance.userVehicleKeys.insert(DB.sharedInstance.currVehicleInfo!["vin"]!)
        DB.sharedInstance.userVehicles[DB.sharedInstance.currVehicleInfo!["vin"]!] = [:]
        DB.sharedInstance.getUserVehicleInfo()
    }
    
    func modifyButtons() {
        if showSkip {
            skipButton.setTitle("Cancel", for: .normal)
            skipButton.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        }
        
        if !(DB.sharedInstance.userVehicles.keys.contains(DB.sharedInstance.currVehicleInfo!["vin"]!)) {
            doneButton.isHidden = false
        }
    }
}
