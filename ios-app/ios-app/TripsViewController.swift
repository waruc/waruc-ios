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
    
    @IBOutlet weak var bottomStartStopTrackingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Table view setup 
        tripTableView.delegate = self
        tripTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        if States.Activity.track {
//            setBlack()
//        } else {
//            setWhite()
//        }
    }    

    @IBAction func send(_ sender: UIButton) {
        States.Activity.track = !States.Activity.track
//        print("Trips switched to \(States.Activity.track)")
//        if (States.Activity.track) {
//            setBlack()
//        } else {
//            setWhite()
//        }
    }
    
    public func setBlack() {
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
    }
    
    
    
    // NSNotification for starting/stopping tracking
    let toggleTracking = Notification.Name(rawValue: "toggleTracking")

    // MARK: TableViewDelegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    var fakeNews = [["8", "7:32 a.m.", "7.82 miles", "April"],
                    ["12", "8:46 a.m.", "9.87 miles", "April"],
                    ["13", "5:00 p.m.", "17.34 miles", "April"],
                    ["15", "7:00 a.m.", "4.36 miles", "April"],
                    ["24", "7:00 p.m.", "101.75 miles", "April"],
                    ["8", "7:32 a.m.", "7.82 miles", "March"],
                    ["12", "8:46 a.m.", "9.87 miles", "March"],
                    ["13", "5:00 p.m.", "17.34 miles", "March"],
                    ["15", "7:00 a.m.", "4.36 miles", "March"],
                    ["24", "7:00 p.m.", "101.75 miles", "March"]]
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tripTableView.dequeueReusableCell(withIdentifier: "tripCell", for: indexPath) as! TripTableViewCell
        
//        cell.dayLabel?.text = "14"
//        cell.timeLabel?.text = "7:00 a.m."
//        cell.distanceLabel?.text = "7.82 miles"
//        cell.monthLabel?.text = "June"
        
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
