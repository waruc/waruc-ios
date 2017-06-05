//
//  AboutPrivacyPolicyViewController.swift
//  ios-app
//
//  Created by Babbs, Dylan on 5/21/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit

class AboutPrivacyPolicyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = Colors.green
        
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.tabBarController?.tabBar.isHidden = true
        
    }
}
