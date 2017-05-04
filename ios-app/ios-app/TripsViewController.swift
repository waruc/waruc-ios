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
    
    
    //Header
    @IBOutlet weak var mytripsHeader: UILabel!
    @IBOutlet weak var mileCountLabel: UILabel!
    @IBOutlet weak var totalMilesLabel: UILabel!
    
    
    
    //Bottom area
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var trackingStatusLabel: UILabel!

    
    @IBOutlet weak var tripTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bottomBar.backgroundColor = Colors.green
        
        // Table view setup 
        tripTableView.delegate = self
        tripTableView.dataSource = self
        
        // NSNotificationCenter for starting and stopping tracking setup
        // Register to receive notification
        NotificationCenter.default.addObserver(self, selector: #selector(TripsViewController.didToggleTracking), name: toggleTracking, object: nil)
        
        //See state
        print("Trips state is \(States.Activity.track)")
         
        
        //@Ishan, here is the observer:
        /*
        NotificationCenter.default.addObserver(self, 
                                               selector: #selector(appWillEnterForeground),
                                               name: NSNotification.Name.UIApplicationDidBecomeActive,
                                               object: nil)
        */
        
    }
    
    
    //Below code is work in progress from master.swift trying to update color
    public func sayHi() {
        print("hi")
    }
    

    @IBAction func send(_ sender: UIButton) {
        States.Activity.track = !States.Activity.track
        print("Trips switched to \(States.Activity.track)")
        setBlack()
    }
    public func setBlack() {
        //Main and header
        self.view.backgroundColor = Colors.backgroundBlack
        mytripsHeader.textColor = Colors.white
        totalMilesLabel.textColor = Colors.white
        
        //Tableview
        self.tripTableView.backgroundColor = Colors.backgroundBlack
        
        //Bottom bar
        bottomBar.backgroundColor = Colors.purple
        trackingStatusLabel.text = "Tracking..."
        
        
        
    }
    func setWhite() {
        view.backgroundColor = UIColor.white
    }
    //end work in progress code
    
    
    
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
