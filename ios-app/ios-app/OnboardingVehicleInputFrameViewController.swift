//
//  OnboardingVehicleInputFrameViewController.swift
//  ios-app
//
//  Created by Babbs, Dylan on 5/20/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit

class OnboardingVehicleInputFrameViewController: UIViewController {
    
    var hideSkip = false

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.layer.cornerRadius = CGFloat(Constants.round)
        skipButton.layer.cornerRadius = CGFloat(Constants.round)
        
        if hideSkip {
            skipButton.isHidden = true
        }
    }
    
    @IBAction func vehicleSubmit(_ sender: Any) {
        if DB.sharedInstance.newVehicle {
            DB.sharedInstance.registerVehicle()
        }
    }
}
