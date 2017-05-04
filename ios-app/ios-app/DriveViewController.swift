//
//  ProfileViewController.swift
//  ios-app
//
//  Created by ishansaksena on 4/7/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit
import GoogleMaps

class DriveViewController: UIViewController {
    
    // MARK: References
    //Main header
    @IBOutlet weak var cityHeader: UILabel!
    
    //Pairing area
    @IBOutlet weak var connectionTypeHeader: UILabel!
    @IBOutlet weak var connectionTypeSubHeader: UILabel!
    @IBOutlet weak var connectionImage: UIImageView!
    @IBOutlet weak var greyBoxOne: UILabel!
    
    //Vehicle area
    @IBOutlet weak var vehicleHeader: UILabel!
    @IBOutlet weak var vehicleSubHeader: UILabel!
    @IBOutlet weak var vehicleImage: UIImageView!
    @IBOutlet weak var greyBoxTwo: UILabel!
    
    //Bottom tracking bar
    @IBOutlet weak var bottomTrackingStatus: UILabel!
    @IBOutlet weak var bottomStartStopTrackingButton: UIButton!
    @IBOutlet weak var bottomBar: UIView!

    // NSNotification for starting/stopping tracking
    let toggleTracking = Notification.Name(rawValue: "toggleTracking")
    
    // MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* TODO: Get user data */
        
        self.greyBoxOne.layer.cornerRadius = 6.0
        self.greyBoxOne.clipsToBounds = true
        self.greyBoxTwo.layer.cornerRadius = 6.0
        self.greyBoxTwo.clipsToBounds = true
        
        self.bottomBar.backgroundColor = Colors.green
        
        // NSNotificationCenter for starting and stopping tracking setup
        // Register to receive notification
        NotificationCenter.default.addObserver(self, selector: #selector(DriveViewController.didToggleTracking), name: toggleTracking, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.didToggleTracking), name: toggleTracking, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TripsViewController.didToggleTracking), name: toggleTracking, object: nil)
        
        //debug:
        print("on start \(States.Activity.track)")
        
        geocoder()

    }
    
    @IBAction public func send(_ sender: UIButton) {
        States.Activity.track = !States.Activity.track
        print("Drives state switch to \(States.Activity.track)")
        if (States.Activity.track) {
            setBlack()
        } else {
            setWhite()
        }
        

        
        // Post toggle tracking notification
        NotificationCenter.default.post(name: toggleTracking, object: nil)
    }
    
    func setBlack() {
        //bars
        self.bottomBar.backgroundColor = Colors.purple
        self.view.backgroundColor = Colors.backgroundBlack
        
        //grey images
        self.greyBoxOne.backgroundColor = Colors.darkGrey
        self.greyBoxTwo.backgroundColor = Colors.darkGrey
        
        
        //text
        self.cityHeader.textColor = Colors.white
        self.bottomTrackingStatus.text = "Tracking..."
        self.connectionTypeHeader.textColor = Colors.white
        self.vehicleHeader.textColor = Colors.white
        self.connectionTypeSubHeader.textColor = Colors.darkGrey
        self.vehicleSubHeader.textColor = Colors.darkGrey

    }
    
    func setWhite() {
        //bars
        self.bottomBar.backgroundColor = Colors.green
        self.view.backgroundColor = Colors.white
        
        //grey images
        self.greyBoxOne.backgroundColor = Colors.darkGrey
        self.greyBoxTwo.backgroundColor = Colors.darkGrey
        
        
        //text
        self.cityHeader.textColor = Colors.black
        self.bottomTrackingStatus.text = "Not Tracking"
        self.connectionTypeHeader.textColor = Colors.black
        self.vehicleHeader.textColor = Colors.black
        self.connectionTypeSubHeader.textColor = Colors.lightGrey
        self.vehicleSubHeader.textColor = Colors.lightGrey
    }
    
    // MARK: NSNotification Listeners
    // The user started or stopped tracking 
    func didToggleTracking() {
        //print("Did toggle tracking distance in drive view Controller")
    }
    
    func geocoder() {
        let geocoder = GMSGeocoder()
        var result = "geocode"
        
        var tempLatLong = CLLocationCoordinate2D(latitude: 47.608013, longitude: -122.335167)
        geocoder.reverseGeocodeCoordinate(tempLatLong) {
            response , error in
            if let address = response?.firstResult() {
                print("why didn't we get in here")
                if address.locality == nil || address.administrativeArea == nil {
                    result = "Somewhere on Planet Earth"
                } else {
                    result = "\(address.locality!), \(address.administrativeArea!)"
                }
            }
            self.cityHeader.text = result
        }
        
    }
}
