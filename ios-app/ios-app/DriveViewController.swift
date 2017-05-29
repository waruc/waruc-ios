//
//  ProfileViewController.swift
//  ios-app
//
//  Created by ishansaksena on 4/7/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit
//import GoogleMaps
//import CoreLocation
import NVActivityIndicatorView

class DriveViewController: UIViewController { //, CLLocationManagerDelegate {
    
    // MARK: References
    //Main header
    @IBOutlet weak var cityHeader: UILabel!
    @IBOutlet weak var locationIcon: UIImageView!
    
    //Pairing area
    @IBOutlet weak var connectionTypeHeader: UILabel!
    @IBOutlet weak var connectionTypeSubHeader: UILabel!
    @IBOutlet weak var greyBoxOne: UILabel!
    @IBOutlet weak var connectionTypeLogo: UIImageView!
    
    //Vehicle area
    @IBOutlet weak var vehicleHeader: UILabel!
    @IBOutlet weak var vehicleSubHeader: UILabel!
    @IBOutlet weak var greyBoxTwo: UILabel!
    @IBOutlet weak var vehicleMakeLogo: UIImageView!
    
    //Bottom tracking bar
    @IBOutlet weak var bottomTrackingStatus: UILabel!
    @IBOutlet weak var bottomStartStopTrackingButton: UIButton!
    @IBOutlet weak var bottomBar: UIView!
    
    @IBOutlet weak var animationView: UIView!
    
    var searchingAnimation: NVActivityIndicatorView?
    
    @IBOutlet weak var connectionHeaderTop: NSLayoutConstraint!
    @IBOutlet weak var vehicleHeaderTop: NSLayoutConstraint!
    
    // MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cityHeader.text = "Drive"
        locationIcon.isHidden = true
        
        bottomStartStopTrackingButton.isHidden = true
        
        searchingAnimation = NVActivityIndicatorView(frame: CGRect(x: 10, y: 10, width: 32, height: 32))
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
        
        //Location services:
        //locationManager = CLLocationManager()

        //Change below to kCLLocationAccuracyBestForNavigation if we need location tracking
        
        //location()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.updateConnection),
                                               name: BLERouter.sharedInstance.connectionTypeNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.displayConnectionStrength),
                                               name: BLERouter.sharedInstance.connectionStrengthNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.updateColorScheme),
                                               name: BLERouter.sharedInstance.colorUpdateNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.updateVehicleInfo),
                                               name: DB.sharedInstance.existingVehicleInfoNotification,
                                               object: nil)
        
        if BLERouter.sharedInstance.connectionType != nil {
            updateConnection()
        }
        
        if BLERouter.sharedInstance.bleConnectionStrength != nil {
            displayConnectionStrength()
        }
        
        if DB.sharedInstance.currVehicleInfo != nil &&
            DB.sharedInstance.userVehicles.keys.contains(DB.sharedInstance.currVehicleInfo!["vin"]!) {
            updateVehicleInfo()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        if BLERouter.sharedInstance.tracking {
            setBlack()
        } else {
            setWhite()
        }
    }
    
    @IBAction public func send(_ sender: UIButton) {
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
    
    //----- The following code is for location services to be added following first
    //----- apple submission.
    
//    func location() {
//        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
//        locationManager.distanceFilter = 1500.0
//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
//        startLocation = nil
//    }
    
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        // App may no longer be authorized to obtain location
//        //information. Check status here and respond accordingly
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let latestLocation: CLLocation = locations[locations.count - 1]
//        var currentLatitude:Double = latestLocation.coordinate.latitude
//        var currentLongitude:Double = latestLocation.coordinate.longitude
//        
//        if startLocation == nil {
//            startLocation = latestLocation
//        }
//        
//        //Geocoder:
//        let geocoder = GMSGeocoder()
//        var result = "result"
//        var temp = CLLocationCoordinate2D(latitude: currentLatitude, longitude: currentLongitude)
//        geocoder.reverseGeocodeCoordinate(temp) {
//            response , error in
//            if let address = response?.firstResult() {
//                if address.locality == nil || address.administrativeArea == nil {
//                    result = "Unknown, USA"
//                } else {
//                    if address.administrativeArea! != "Washington" {
//                        let city = "\(address.locality!), \(address.administrativeArea!)"
//                        result = "Outside of WA"
//                    } else {
//                        result = "\(address.locality!), WA"
//                    }
//                    print("CITY: \(result)")
//                }
//            }
//            self.cityHeader.text = result
//            self.locationIcon.isHidden = false
//            self.transition(item: self.locationIcon)
//            self.transition(item: self.cityHeader)
//        }
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        // Handle errors here 
//    }
    
    func updateConnection() {
        if BLERouter.sharedInstance.connectionType != nil {
            connectionTypeLogo.image = #imageLiteral(resourceName: "bluetooth")
            searchingAnimation?.stopAnimating()
            
            connectionHeaderTop.constant -= 12
            connectionTypeHeader.text = BLERouter.sharedInstance.connectionType
        } else {
            connectionTypeLogo.image = nil
            connectionTypeSubHeader.text = ""
            searchingAnimation?.startAnimating()
            connectionHeaderTop.constant += 12
            connectionTypeHeader.text = "Searching"
        }
    }
    
    func displayConnectionStrength() {
        connectionTypeSubHeader.text = BLERouter.sharedInstance.bleConnectionStrength!
    }
    
    func updateVehicleInfo() {
        if DB.sharedInstance.currVehicleInfo != nil {
            vehicleMakeLogo.image = UIImage(named: "\(DB.sharedInstance.currVehicleInfo!["make"]!.lowercased())_logo")
            vehicleHeaderTop.constant -= 12
            if DB.sharedInstance.currVehicleInfo!["nickname"] == nil {
                vehicleHeader.text = "\(DB.sharedInstance.currVehicleInfo!["make"]!.capitalized)"
                vehicleSubHeader.text = "\(DB.sharedInstance.currVehicleInfo!["year"]!) \(DB.sharedInstance.currVehicleInfo!["model"]!)"
            } else {
                vehicleHeader.text = "\(DB.sharedInstance.currVehicleInfo!["nickname"]!)"
                vehicleSubHeader.text = "\(DB.sharedInstance.currVehicleInfo!["year"]!) \(DB.sharedInstance.currVehicleInfo!["make"]!.capitalized) \(DB.sharedInstance.currVehicleInfo!["model"]!)"
            }
        } else {
            vehicleMakeLogo.image = nil
            vehicleHeaderTop.constant += 12
            vehicleHeader.text = "Vehicle not connected"
            vehicleSubHeader.text = ""
        }
    }
}
