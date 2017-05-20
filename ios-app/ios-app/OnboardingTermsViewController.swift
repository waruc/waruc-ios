//
//  OnboardingTermsViewController.swift
//  ios-app
//
//  Created by Babbs, Dylan on 5/20/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit

class OnboardingTermsViewController: UIViewController {
    @IBOutlet weak var acceptButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.acceptButton.layer.cornerRadius = 4
        acceptButton.clipsToBounds = true
        
        self.navigationController?.navigationBar.tintColor = Colors.green
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
}
