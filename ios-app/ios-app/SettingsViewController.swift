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

    @IBOutlet weak var profileInitials: UILabel!
    
    @IBOutlet weak var settingsHeader: UILabel!
    @IBOutlet weak var bottomBar: UIView!

    
    @IBOutlet weak var trackingStatusLabel: UILabel!
    
    @IBOutlet weak var bottomStartStopTrackingButton: UIButton!
    
    
    // MARK: Setup 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bottomBar.backgroundColor = Colors.green
        
        //bottomStartStopTrackingButton.isHidden = true
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.updateColorScheme),
                                               name: BLERouter.sharedInstance.colorUpdateNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.toggleStartButton),
                                               name: Notification.Name("toggleStartNotificationIdentifier"),
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.tabBarController?.tabBar.isHidden = false
        if BLERouter.sharedInstance.tracking {
            setBlack()
        } else {
            setWhite()
        }
        
        bottomStartStopTrackingButton.isHidden = true
        if UserDefaults.standard.value(forKey: "ble_tracking") == nil && UserDefaults.standard.value(forKey: "location_tracking") != nil {
            bottomStartStopTrackingButton.isHidden = false
        }
    }
    
    //Below code is work in progress from master.swift trying to update color
    @IBAction func send(_ sender: UIButton) {
        BLERouter.sharedInstance.tracking = !BLERouter.sharedInstance.tracking
        updateColorScheme()
    }
    
    func updateColorScheme() {
        if BLERouter.sharedInstance.tracking {
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
        view.backgroundColor = Colors.tableGrey
        settingsHeader.textColor = Colors.black

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
    
    func toggleStartButton() {
        bottomStartStopTrackingButton.isHidden = !bottomStartStopTrackingButton.isHidden
    }
}
