//
//  TabBarViewController.swift
//  ios-app
//
//  Created by Babbs, Dylan on 4/30/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "authedAddNewVehicle" {
            if let toViewController = segue.destination as? OnboardingVehicleInputFrameViewController {
                toViewController.showCancel = true
            }
        }
    }
}
