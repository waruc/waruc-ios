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
    
    var fakeNews = [[String]]()
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fakeNews = delegate.router.trips
        self.mileCountLabel.text = "\(Int(delegate.router.aggDist.rounded(.toNearestOrAwayFromZero)))"
        
        // Table view setup 
        self.tripTableView.delegate = self
        self.tripTableView.dataSource = self
        
        self.tripTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(self.refreshData(sender:)), for: .valueChanged)
        
        loadFeed()
        
        
        // Realm trial
        let d = Date(timeIntervalSince1970: 0)
        writeTrip(date: d, distance: 5.0, deviceID: "1")
        let trips = readTrip()
        print(trips[0])
        
    }
    
    func refreshData(sender: UIRefreshControl) {
        loadFeed()
        self.refreshControl.endRefreshing()
    }
    
    func loadFeed() {
        self.fakeNews = delegate.router.trips
        self.tripTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if States.Activity.track {
            setBlack()
        } else {
            setWhite()
        }
    }    

    @IBAction func send(_ sender: UIButton) {
        States.Activity.track = !States.Activity.track
        print("Trips switched to \(States.Activity.track)")
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
        return fakeNews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tripTableView.dequeueReusableCell(withIdentifier: "tripCell", for: indexPath) as! TripTableViewCell
        
        var news = fakeNews[indexPath.row]
        
        cell.dayLabel?.text = news[0]
        cell.timeLabel?.text = news[1]
        cell.distanceLabel?.text = news[2]
        cell.monthLabel?.text = news[3]
        
        
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
}
