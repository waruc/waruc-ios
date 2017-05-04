//
//  TripsViewController.swift
//  ios-app
//
//  Created by ishansaksena on 4/30/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit

class TripsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: References
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var tripTableView: UITableView!
    
    var green = UIColor(red:0.22, green:0.78, blue:0.51, alpha:1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bottomBar.backgroundColor = green
        
        // Table view setup 
        tripTableView.delegate = self
        tripTableView.dataSource = self
        
        // NSNotificationCenter for starting and stopping tracking setup
        // Register to receive notification
        NotificationCenter.default.addObserver(self, selector: #selector(TripsViewController.didToggleTracking), name: toggleTracking, object: nil)
    }
    
    // NSNotification for starting/stopping tracking
    let toggleTracking = Notification.Name(rawValue: "toggleTracking")

    // MARK: TableViewDelegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tripTableView.dequeueReusableCell(withIdentifier: "tripCell", for: indexPath) as! TripTableViewCell
        
        cell.dayLabel?.text = "14"
        cell.timeLabel?.text = "7:00 a.m."
        cell.distanceLabel?.text = "7.82 miles"
        cell.monthLabel?.text = "June"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    // MARK: NSNotification Listeners
    // The user started or stopped tracking 
    func didToggleTracking() {
        print("Did toggle tracking distance in TripsViewController")
    }
}
