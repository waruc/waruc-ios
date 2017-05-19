//
//  TripsViewController.swift
//  ios-app
//
//  Created by ishansaksena on 4/30/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit
import Foundation

class TripsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var tripsView: UIView!
    @IBOutlet weak var mytripsHeader: UILabel!
    @IBOutlet weak var mileCountLabel: UILabel!
    @IBOutlet weak var totalMilesLabel: UILabel!
    
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var trackingStatusLabel: UILabel!

    @IBOutlet weak var tripTableView: UITableView!
    
    @IBOutlet weak var bottomStartStopTrackingButton: UIButton!
    
    @IBOutlet weak var vehicleDropdownButton: UIButton!
    var vehiclePickerView:UIPickerView?
    
    var realmTrips = [Trip]()
    
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if DB.sharedInstance.userVehicles.isEmpty {
            vehicleDropdownButton.isHidden = true
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.createVehiclePicker),
                                                   name: DB.sharedInstance.userVehiclesNotification,
                                                   object: nil)
        } else {
            createVehiclePicker()
        }
        
        realmTrips = Array(readTrip())
        self.mileCountLabel.text = "\(Int(getTotalMiles().rounded(.toNearestOrAwayFromZero)))"
        
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
        
        loadFeed()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.updateColorScheme),
                                               name: BLERouter.sharedInstance.colorUpdateNotification,
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
        if BLERouter.sharedInstance.tracking {
            setBlack()
        } else {
            setWhite()
        }
    }

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
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func getTotalMiles() -> Double {
        return realmTrips.map { $0.distance }.reduce(0.0, +)
    }
    
    func createVehiclePicker() {
        print("createVehiclePicker")
        vehiclePickerView = UIPickerView()
        let pickerX = vehicleDropdownButton.frame.origin.x - 220
        let pickerY = vehicleDropdownButton.frame.origin.y + vehicleDropdownButton.frame.height - 5
        vehiclePickerView!.dataSource = self
        vehiclePickerView!.delegate = self
        vehiclePickerView!.frame = CGRect(x: pickerX, y: pickerY, width: 250, height: 100)
        vehiclePickerView!.backgroundColor = UIColor.black
        vehiclePickerView!.layer.borderColor = UIColor.white.cgColor
        vehiclePickerView!.layer.cornerRadius = 5
        vehiclePickerView!.layer.borderWidth = 1
        vehiclePickerView!.isHidden = true
        tripsView.addSubview(vehiclePickerView!)
        
        vehicleDropdownButton.isHidden = false
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return DB.sharedInstance.userVehicles.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.text = DB.sharedInstance.userVehicles[row].values.joined(separator: " ")
        pickerLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        pickerLabel.font = UIFont.systemFont(ofSize: 20)
        pickerLabel.textAlignment = NSTextAlignment.center
        return pickerLabel
    }
    
    @IBAction func showVehicleDropdown(_ sender: Any) {
        vehiclePickerView!.isHidden = !vehiclePickerView!.isHidden
    }
}
