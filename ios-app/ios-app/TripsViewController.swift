//
//  TripsViewController.swift
//  ios-app
//
//  Created by ishansaksena on 4/30/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit
import Foundation
import AudioToolbox

class TripsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var mytripsHeader: UILabel!
    @IBOutlet weak var mileCountLabel: UILabel!
    @IBOutlet weak var totalMilesLabel: UILabel!
    
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var trackingStatusLabel: UILabel!

    @IBOutlet weak var tripTableView: UITableView!
    
    @IBOutlet weak var bottomStartStopTrackingButton: UIButton!
    
    var firebaseTrips = [[String: Any]]()
    
    private let refreshControl = UIRefreshControl()
    
    let tripFilterNotificationIdentifier = Notification.Name("tripFilterNotificationIdentifier")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //bottomStartStopTrackingButton.isHidden = true
        
        // Separator for top of first cell
        let px = 1 / UIScreen.main.scale
        let frame = CGRect(x: 0, y: 0, width: self.tripTableView.frame.size.width, height: px)
        let line = UIView(frame: frame)
        self.tripTableView.tableHeaderView = line
        line.backgroundColor = self.tripTableView.separatorColor
        
        // Table view setup 
        self.tripTableView.delegate = self
        self.tripTableView.dataSource = self
        
        self.tripTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(self.refreshData(sender:)), for: .valueChanged)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.updateColorScheme),
                                               name: BLERouter.sharedInstance.colorUpdateNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.filterTrips(_:)),
                                               name: tripFilterNotificationIdentifier,
                                               object: nil)
        
        if DB.sharedInstance.userTrips != nil {
            updateTripsTable()
        } else {
            DB.sharedInstance.fetchUserTrips() { (returnedTrips) in
                DB.sharedInstance.userTrips = returnedTrips
                
                self.updateTripsTable()
            }
        }
    }
    
    func refreshData(sender: UIRefreshControl) {
        DB.sharedInstance.fetchUserTrips() { (returnedTrips) in
            DB.sharedInstance.userTrips = returnedTrips
            
            self.updateTripsTable()
        }
    }
    
    func updateTripsTable() {
        DB.sharedInstance.userTotalMiles = DB.sharedInstance.userTrips!.count > 0 ?
            Array(DB.sharedInstance.userTrips!.map { (($0["mileage"] as! Double) * 10).rounded() / 10 }).reduce(0.0, +) : 0.0
        
        self.mileCountLabel.text = "\(Int((DB.sharedInstance.userTotalMiles?.rounded(.toNearestOrAwayFromZero))!))"
        
        DB.sharedInstance.userTrips = DB.sharedInstance.userTrips!.sorted(by: { $0["timestamp"] as! Int > $1["timestamp"] as! Int })
        
        self.refreshControl.endRefreshing()
        self.tripTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        if BLERouter.sharedInstance.tracking || Location.sharedInstance.tracking {
            setBlack()
        } else {
            setWhite()
        }
        
        bottomStartStopTrackingButton.isHidden = true
        if UserDefaults.standard.value(forKey: "ble_tracking") == nil && UserDefaults.standard.value(forKey: "location_tracking") != nil {
            bottomStartStopTrackingButton.isHidden = false
        }
    }
    
    @IBAction func send(_ sender: UIButton) {
        BLERouter.sharedInstance.tracking = !BLERouter.sharedInstance.tracking
        Location.sharedInstance.tracking = !Location.sharedInstance.tracking
        
        if Location.sharedInstance.tracking {
            Location.sharedInstance.startTracking()
        } else {
            Location.sharedInstance.stopTracking()
        }
        
        updateColorScheme()
    }
    
    func updateColorScheme() {
        if BLERouter.sharedInstance.tracking || Location.sharedInstance.tracking {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate)) 
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
        
        for cell in self.tripTableView.visibleCells as! Array<TripTableViewCell> {
            cell.distanceLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        
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
        
        for cell in self.tripTableView.visibleCells as! Array<TripTableViewCell> {
            cell.distanceLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
        
        //Transitions
        transition(item: self.view)
        transition(item: (self.tabBarController?.tabBar)!)
    }

    // MARK: TableViewDelegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (DB.sharedInstance.userTrips ?? []).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tripTableView.dequeueReusableCell(withIdentifier: "tripCell", for: indexPath) as! TripTableViewCell
        
        let currTrip = DB.sharedInstance.userTrips![indexPath.row]
        
        let calendar = Calendar.current
        let date = Date.init(timeIntervalSince1970: TimeInterval((currTrip["timestamp"] as! Int)))
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "PST")!
        formatter.dateFormat = "h:mm a"
        
        cell.dayLabel?.text = "\(calendar.component(.day, from: date))"
        cell.timeLabel?.text = "\(formatter.string(from: date))"
        cell.distanceLabel?.text = "\((((currTrip["mileage"] as! Double) * 10).rounded() / 10)) miles"
        cell.monthLabel?.text = "\(calendar.shortMonthSymbols[calendar.component(.month, from: date) - 1])"
        
        cell.distanceLabel.textColor = BLERouter.sharedInstance.tracking ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func updateTotalMiles() {
        self.mileCountLabel.text = "\(Int(DB.sharedInstance.userTotalMiles!.rounded(.toNearestOrAwayFromZero)))"
    }

    @IBAction func filterByVehicle(_ sender: Any) {
        //addCategory()
        
        let mainStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        let popoverController = mainStoryboard.instantiateViewController(withIdentifier: "VehiclePickerVC") as UIViewController
        // set the presentation style
        popoverController.modalPresentationStyle = UIModalPresentationStyle.popover
        
        // set up the popover presentation controller
        popoverController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
        popoverController.popoverPresentationController?.delegate = self
        popoverController.popoverPresentationController?.sourceView = (sender as! UIView) // button
        popoverController.popoverPresentationController?.sourceRect = (sender as AnyObject).bounds
        popoverController.popoverPresentationController?.backgroundColor = UIColor.black
        
        popoverController.preferredContentSize = CGSize(width: 300, height: 150)
        
        // present the popover
        self.present(popoverController, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func filterTrips(_ notification: NSNotification) {
        if let selectedVehicle = (notification.object as? [String: String]) {
            DB.sharedInstance.fetchUserTripsByVin(vin: selectedVehicle["vin"]!) { (returnedTrips) in
                DB.sharedInstance.userTrips = returnedTrips
                
                self.updateTripsTable()
            }
        } else {
            DB.sharedInstance.fetchUserTrips() { (returnedTrips) in
                DB.sharedInstance.userTrips = returnedTrips
                
                self.updateTripsTable()
            }
        }

    }
    
}
