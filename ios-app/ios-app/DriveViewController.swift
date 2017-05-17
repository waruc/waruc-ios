//
//  ProfileViewController.swift
//  ios-app
//
//  Created by ishansaksena on 4/7/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import NVActivityIndicatorView

class DriveViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: References
    //Main header
    @IBOutlet weak var cityHeader: UILabel!
    @IBOutlet weak var locationIcon: UIImageView!
    
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
    
    @IBOutlet weak var animationView: UIView!
    
    var searchingAnimation: NVActivityIndicatorView?

    //Location services
    var locationManager: CLLocationManager = CLLocationManager()
    var startLocation: CLLocation!
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchingAnimation = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 54, height: 27))
        searchingAnimation!.color = UIColor.black
        //searchingAnimation = .ballScaleRippleMultiple
        searchingAnimation!.startAnimating()
        self.animationView.addSubview(searchingAnimation!)
        
        self.greyBoxOne.layer.cornerRadius = 6.0
        self.greyBoxOne.clipsToBounds = true
        self.greyBoxTwo.layer.cornerRadius = 6.0
        self.greyBoxTwo.clipsToBounds = true
        
        self.bottomBar.backgroundColor = Colors.green
        locationIcon.isHidden = true
        
        //debug:
        print("on start \(States.Activity.track)")
        
        //Location services:
        //locationManager = CLLocationManager()

        //Change below to kCLLocationAccuracyBestForNavigation if we need location tracking
        
        location()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateConnection),
                                               name: delegate.router.connectionTypeNotification, object: nil)
    }

    func startScanning() {
        let uuid = UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")!
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 123, minor: 456, identifier: "MyBeacon")
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
    }
    
    
    @IBAction public func send(_ sender: UIButton) {
        States.Activity.track = !States.Activity.track
        print("Drives state switch to \(States.Activity.track)")
        if (States.Activity.track) {
            setBlack()
        } else {
            setWhite()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if States.Activity.track {
            setBlack()
        } else {
            setWhite()
        }
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

        self.searchingAnimation!.color = UIColor.white
        if self.searchingAnimation!.animating {
            self.searchingAnimation!.startAnimating()
        }
        self.connectionTypeHeader.textColor = Colors.white
        self.vehicleHeader.textColor = Colors.white
        self.connectionTypeSubHeader.textColor = Colors.darkGrey
        self.vehicleSubHeader.textColor = Colors.darkGrey
        
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
        //bars
        self.bottomBar.backgroundColor = Colors.green
        self.view.backgroundColor = Colors.white
        
        //grey images
        self.greyBoxOne.backgroundColor = Colors.lightGrey
        self.greyBoxTwo.backgroundColor = Colors.lightGrey
        
        //text
        self.cityHeader.textColor = Colors.black
        self.bottomTrackingStatus.text = "Not Tracking"
        
        self.searchingAnimation!.color = UIColor.black
        if self.searchingAnimation!.animating {
            self.searchingAnimation!.startAnimating()
        }
        self.connectionTypeHeader.textColor = Colors.black
        self.vehicleHeader.textColor = Colors.black
        self.connectionTypeSubHeader.textColor = Colors.darkGrey
        self.vehicleSubHeader.textColor = Colors.darkGrey
        
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
    
    func transition(item: UIView) {
        UIView.transition(with: item,
                          duration: Colors.transitionTime,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
    }
    
    func location() {
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 1500.0
        
        locationManager.delegate = self
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        startLocation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // App may no longer be authorized to obtain location
        //information. Check status here and respond accordingly
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let latestLocation: CLLocation = locations[locations.count - 1]
        var currentLatitude:Double = latestLocation.coordinate.latitude
        var currentLongitude:Double = latestLocation.coordinate.longitude
        
        if startLocation == nil {
            startLocation = latestLocation
        }
        
        //Geocoder:
        let geocoder = GMSGeocoder()
        var result = "result"
        var temp = CLLocationCoordinate2D(latitude: currentLatitude, longitude: currentLongitude)
        geocoder.reverseGeocodeCoordinate(temp) {
            response , error in
            if let address = response?.firstResult() {
                if address.locality == nil || address.administrativeArea == nil {
                    result = "Unknown, USA"
                } else {
                    
                    if address.administrativeArea! != "Washington" {
                        let city = "\(address.locality!), \(address.administrativeArea!)"
                        result = "Outside of WA"
                    } else {
                        result = "\(address.locality!), WA"
                    }
                    print("CITY: \(result)")
                }
            }
            self.cityHeader.text = result
            self.locationIcon.isHidden = false
            self.transition(item: self.locationIcon)
            self.transition(item: self.cityHeader)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Handle errors here 
    }
    
    func updateConnection() {
        if delegate.router.connectionType != nil {
            self.searchingAnimation?.stopAnimating()
            self.connectionTypeHeader.text = delegate.router.connectionType
        } else {
            self.searchingAnimation?.startAnimating()
            self.connectionTypeHeader.text = "Searching"
        }
    }
}
