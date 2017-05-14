//
//  SettingsViewController.swift
//  ios-app
//
//  Created by ishansaksena on 4/7/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    // MARK: References
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileImage: UIImageView!

    @IBOutlet weak var profileInitials: UILabel!
    
    @IBOutlet weak var settingsHeader: UILabel!
    @IBOutlet weak var bottomBar: UIView!
    //@IBOutlet weak var settingsTableView: UITableView!
    
    @IBOutlet weak var trackingStatusLabel: UILabel!
    
    @IBOutlet weak var bottomStartStopTrackingButton: UIButton!
    // NSNotification for starting/stopping tracking
    let toggleTracking = Notification.Name(rawValue: "toggleTracking")
    
    // MARK: Setup 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
        self.profileImage.clipsToBounds = true
        
        self.bottomBar.backgroundColor = Colors.green

        
        // NSNotificationCenter for starting and stopping tracking setup
        // Register to receive notification
        
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.didToggleTracking), name: toggleTracking, object: nil)
        print("Settings state is \(States.Activity.track)")
        //Set black/white UI
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if States.Activity.track {
            setBlack()
        } else {
            setWhite()
        }
    } 
    
    
    //Below code is work in progress from master.swift trying to update color
    @IBAction func send(_ sender: UIButton) {
        States.Activity.track = !States.Activity.track
        print("Settings state switched to \(States.Activity.track)")
        if (States.Activity.track) {
            setBlack()
        } else {
            setWhite()
        }
    }
    
    func transition(item: UIView) {
        UIView.transition(with: item,
                          duration: Colors.transitionTime,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
    }
    
   
    
    func setBlack() {
        //Main and header
        view.backgroundColor = Colors.backgroundBlack
        settingsHeader.textColor = Colors.white
        
        //Middle text
        profileName.textColor = Colors.white
        
        //Bottom bar area
        bottomBar.backgroundColor = Colors.purple
        trackingStatusLabel.text = "Tracking..."
        
        //button
        bottomStartStopTrackingButton.setTitle("Stop", for: .normal)
        
        //Tab Bar
        self.tabBarController?.tabBar.backgroundColor = Colors.backgroundBlack
        self.tabBarController?.tabBar.barTintColor = Colors.backgroundBlack
        
        //Status bar
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)

        //Transitions
        transition(item: self.view)
        transition(item: (self.tabBarController?.tabBar)!)
    }
    
    func setWhite() {
        //Main and header
        view.backgroundColor = UIColor.white
        settingsHeader.textColor = Colors.black

        //Middle text
        profileName.textColor = Colors.black
        
        //Bottom bar area
        bottomBar.backgroundColor = Colors.green
        trackingStatusLabel.text = "Not Tracking"
        
        //button
        bottomStartStopTrackingButton.setTitle("Start", for: .normal)
        
        //Tab bar
        self.tabBarController?.tabBar.backgroundColor = UIColor.white
        self.tabBarController?.tabBar.barTintColor = UIColor.white
        
        //Status bar
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.default, animated: true)
        
        //Transitions
        transition(item: self.view)
        transition(item: (self.tabBarController?.tabBar)!)
        
    }
    
    // MARK: NSNotification Listeners
    // The user started or stopped tracking 
    func didToggleTracking() {
        print("Did toggle tracking distance in Settings View Controller")
    }
    
    
}
