//
//  SettingsViewController.swift
//  ios-app
//
//  Created by ishansaksena on 4/7/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: References
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileImage: UIImageView!

    var green = UIColor(red:0.22, green:0.78, blue:0.51, alpha:1.0)
    
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var settingsTableView: UITableView!
    
    // NSNotification for starting/stopping tracking
    let toggleTracking = Notification.Name(rawValue: "toggleTracking")
    
    // MARK: Setup 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
        self.profileImage.clipsToBounds = true
        
        self.bottomBar.backgroundColor = green
        
        // Table View set up
        self.settingsTableView.delegate = self
        self.settingsTableView.dataSource = self
        
        // NSNotificationCenter for starting and stopping tracking setup
        // Register to receive notification
        
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.didToggleTracking), name: toggleTracking, object: nil)
    }

    // MARK: TableViewDelegate Methods     
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Vehicles"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.settingsTableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath) as UITableViewCell
        
        cell.textLabel?.text = "Setting" 
        cell.detailTextLabel?.text = "Current"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    // MARK: NSNotification Listeners
    // The user started or stopped tracking 
    func didToggleTracking() {
        print("Did toggle tracking distance in Settings View Controller")
    }
    
    
}
