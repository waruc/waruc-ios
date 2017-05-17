//
//  TripsViewController.swift
//  ios-app
//
//  Created by ishansaksena on 4/30/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit
import Foundation

class TripsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var mytripsHeader: UILabel!
    @IBOutlet weak var mileCountLabel: UILabel!
    @IBOutlet weak var totalMilesLabel: UILabel!
    
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var trackingStatusLabel: UILabel!

    @IBOutlet weak var tripTableView: UITableView!
    
    @IBOutlet weak var bottomStartStopTrackingButton: UIButton!
    
    var realmTrips = [Trip]()
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        realmTrips = Array(readTrip())
        self.mileCountLabel.text = "\(Int(getTotalMiles().rounded(.toNearestOrAwayFromZero)))"
        
        // Table view setup 
        self.tripTableView.delegate = self
        self.tripTableView.dataSource = self
        
        self.tripTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(self.refreshData(sender:)), for: .valueChanged)
        
        loadFeed()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.updateColorScheme),
                                               name: delegate.router.colorUpdateNotification,
                                               object: nil)
    }
    
    func refreshData(sender: UIRefreshControl) {
        loadFeed()
        self.refreshControl.endRefreshing()
    }
    
    func loadFeed() {
        self.realmTrips = Array(readTrip())
        self.mileCountLabel.text = "\(Int(getTotalMiles().rounded(.toNearestOrAwayFromZero)))"
        self.tripTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.delegate.router.tracking {
            setBlack()
        } else {
            setWhite()
        }
    }

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
        mytripsHeader.textColor = Colors.white
        totalMilesLabel.textColor = Colors.white
        
        //Tableview
        self.tripTableView.backgroundColor = Colors.backgroundBlack
        
        //Bottom bar
        bottomBar.backgroundColor = Colors.purple
        trackingStatusLabel.text = "Tracking..."
        
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
        view.backgroundColor = Colors.white
        totalMilesLabel.textColor = Colors.black
        mytripsHeader.textColor = Colors.black
        
        //Tableview
        self.tripTableView.backgroundColor = Colors.white
        
        //Bottom bar
        bottomBar.backgroundColor = Colors.green
        trackingStatusLabel.text = "Not Tracking"
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
    
    // NSNotification for starting/stopping tracking
    let toggleTracking = Notification.Name(rawValue: "toggleTracking")

    // MARK: TableViewDelegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return realmTrips.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tripTableView.dequeueReusableCell(withIdentifier: "tripCell", for: indexPath) as! TripTableViewCell
        
        let currTrip = realmTrips[indexPath.row]
        
        let calendar = Calendar.current
        let date = Date.init(timeIntervalSince1970: TimeInterval(currTrip.ts))
        
        cell.dayLabel?.text = "\(calendar.component(.day, from: date))"
        cell.timeLabel?.text = "\((((currTrip.duration / 60.0) * 10).rounded() / 10)) min"
        cell.distanceLabel?.text = "\(((currTrip.distance * 10).rounded() / 10)) miles"
        cell.monthLabel?.text = "\(calendar.monthSymbols[calendar.component(.month, from: date) - 1])"
        
        //cell.contentView.backgroundColor = Colors.backgroundBlack
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if States.Activity.track {
//            //setBlack()
//            cell.contentView.backgroundColor = Colors.backgroundBlack
//        } else {
//            //setWhite()
//            cell.contentView.backgroundColor = Colors.white
//        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    // MARK: NSNotification Listeners
    // The user started or stopped tracking 
    func didToggleTracking() {
        print("Did toggle tracking distance in TripsViewController")
    }
    
    func getTotalMiles() -> Double {
        return realmTrips.map { $0.distance }.reduce(0.0, +)
    }
}
