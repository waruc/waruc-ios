//
//  ViewController.swift
//  ios-app
//
//  Created by Nicholas Nordale on 4/1/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var scrollContainer: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adding the Profile View
        let profileView: ProfileViewController = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
        
        self.addChildViewController(profileView)
        self.scrollContainer.addSubview(profileView.view)
        profileView.didMove(toParentViewController: self)
        
        // Adding the Home View
        let homeView: HomeViewController = HomeViewController(nibName: "HomeViewController", bundle: nil)
        
        self.addChildViewController(homeView)
        self.scrollContainer.addSubview(homeView.view)
        homeView.didMove(toParentViewController: self)

        // Adding the Settings View
        let settingsView: SettingsViewController = SettingsViewController(nibName: "SettingsViewController", bundle: nil)
        
        self.addChildViewController(settingsView)
        self.scrollContainer.addSubview(settingsView.view)
        settingsView.didMove(toParentViewController: self)
        
        // Adjusting frames
        // Home
        var homeFrame: CGRect = self.view.frame
        homeFrame.origin.x = self.view.frame.width
        homeView.view.frame = homeFrame
        
        // Settings
        var settingsFrame: CGRect = self.view.frame
        settingsFrame.origin.x = self.view.frame.width * 2
        settingsView.view.frame = settingsFrame
        
        // Setting size of main scrollContainer
        let viewCount: CGFloat = 3
        self.scrollContainer.contentSize = CGSize(width: self.view.frame.width * viewCount, height: self.view.frame.height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Navigates to the view on the right
    // Does nothing if already in the right most view
    func scrollRight() {
        print("Scrolling right")
        print(scrollContainer.contentOffset.x)
        //if() {}
    }
    
    // Navigates to the view on the left
    // Does nothing if already in the left most view
    func scrollLeft() {
        print("Scrolling left")
    }
}

