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

    @IBOutlet weak var profileInitials: UILabel!
    
    @IBOutlet weak var settingsHeader: UILabel!
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var settingsTableView: UITableView!
    
    @IBOutlet weak var trackingStatusLabel: UILabel!
    
    @IBOutlet weak var bottomStartStopTrackingButton: UIButton!
    // NSNotification for starting/stopping tracking
    let toggleTracking = Notification.Name(rawValue: "toggleTracking")
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: Setup 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
        self.profileImage.clipsToBounds = true
        
        self.bottomBar.backgroundColor = Colors.green
        
        // Table View set up
        self.settingsTableView.delegate = self
        self.settingsTableView.dataSource = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.updateColorScheme),
                                               name: delegate.router.colorUpdateNotification,
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.delegate.router.tracking {
            setBlack()
        } else {
            setWhite()
        }
    }
    
    //Below code is work in progress from master.swift trying to update color
    @IBAction func send(_ sender: UIButton) {
        self.delegate.router.tracking = !self.delegate.router.tracking
        updateColorScheme()
    }
    
    func updateColorScheme() {
        if self.delegate.router.tracking {
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
    
    // MARK: TableViewDelegate Methods     
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Vehicles"
        } else {
            return "Personal"
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    var fakeNews = [["Vehicle", "BMW 725i"],
                    ["Location", "On"],
                    ["Units", "Miles"]]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.settingsTableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath) as! SettingsTableViewCell
        
        var news = fakeNews[indexPath.row + indexPath.section]
        cell.settingType.text = news[0]
        cell.currentOption.text = news[1]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    

}
