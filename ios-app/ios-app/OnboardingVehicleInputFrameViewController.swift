//
//  OnboardingVehicleInputFrameViewController.swift
//  ios-app
//
//  Created by Babbs, Dylan on 5/20/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit

class OnboardingVehicleInputFrameViewController: UIViewController {

    @IBOutlet weak var doneButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        doneButton.layer.cornerRadius = CGFloat(Constants.round)
    }
}
