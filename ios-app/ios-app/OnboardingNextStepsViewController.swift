//
//  OnboardingNextStepsViewController.swift
//  ios-app
//
//  Created by Babbs, Dylan on 5/20/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit

class OnboardingNextStepsViewController: UIViewController {

    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nextButton.layer.cornerRadius = CGFloat(Constants.round)
        nextButton.clipsToBounds = true
        self.navigationController?.navigationBar.tintColor = Colors.green
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
}
