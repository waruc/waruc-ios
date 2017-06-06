//
//  OnboardingOBDIIViewController.swift
//  ios-app
//
//  Created by Babbs, Dylan on 5/20/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit

class OnboardingOBDIIViewController: UIViewController {
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.skipButton.layer.cornerRadius = CGFloat(Constants.round)
        self.nextButton.layer.cornerRadius = CGFloat(Constants.round)
        nextButton.clipsToBounds = true
        self.navigationController?.navigationBar.tintColor = Colors.green
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "obdPluggedIn" {
            BLERouter.sharedInstance.createSingleton()
            
            if let toViewController = segue.destination as? OnboardingVehicleInputFrameViewController {
                toViewController.showSkip = true
            }
        } else {
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
        }
    }
}
