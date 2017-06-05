//
//  OnboardingEnableFeaturesViewController.swift
//  ios-app
//
//  Created by Babbs, Dylan on 5/20/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit
import CoreBluetooth
//import CoreLocation

class OnboardingEnableFeaturesViewController: UIViewController, /*CLLocationManagerDelegate,*/ CBCentralManagerDelegate, CBPeripheralDelegate {

    @IBOutlet weak var bluetoothImage: UIImageView!
    @IBOutlet weak var bluetoothTitle: UILabel!
    @IBOutlet weak var bluetoothDesc: UILabel!
    
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var locationTitle: UILabel!
    @IBOutlet weak var locationDesc: UILabel!
    
    //location
    //TODO: This code is for next submission when location is ready
//    var locationManager: CLLocationManager = CLLocationManager()
//    var startLocation: CLLocation!
    
    // Bluetooth 
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = Colors.green
        
        let bleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(bleTapped(tapGestureRecognizer:)))
        bluetoothImage.isUserInteractionEnabled = true
        bluetoothImage.addGestureRecognizer(bleTapGestureRecognizer)
        bluetoothTitle.isUserInteractionEnabled = true
        bluetoothTitle.addGestureRecognizer(bleTapGestureRecognizer)
        bluetoothDesc.isUserInteractionEnabled = true
        bluetoothDesc.addGestureRecognizer(bleTapGestureRecognizer)
        
        let locationTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(locationTapped(tapGestureRecognizer:)))
        locationImage.isUserInteractionEnabled = true
        locationImage.addGestureRecognizer(locationTapGestureRecognizer)
        locationTitle.isUserInteractionEnabled = true
        locationTitle.addGestureRecognizer(locationTapGestureRecognizer)
        locationDesc.isUserInteractionEnabled = true
        locationDesc.addGestureRecognizer(locationTapGestureRecognizer)
    }
    
    func bleTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        UserDefaults.standard.setValue("on", forKey: "ble_tracking")
        print("Set user ble_tracking value to: \(UserDefaults.standard.value(forKey: "ble_tracking")!)")
        self.performSegue(withIdentifier: "setupOBD", sender: nil)
    }
    
    func locationTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        UserDefaults.standard.setValue("on", forKey: "location_tracking")
        print("Set user location_tracking value to: \(UserDefaults.standard.value(forKey: "location_tracking")!)")
        self.performSegue(withIdentifier: "manualVehicleCreation", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "manualVehicleCreation" {
            DB.sharedInstance.newVehicle = true
            DB.sharedInstance.currVehicleInfo = [
                "make": "",
                "model": "",
                "year": "",
                "nickname": ""
            ]
        } else {
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
        }
    }
    
    @available(iOS 5.0, *)
    func centralManagerDidUpdateState(_ central: CBCentralManager) {}
    
    @IBAction func enableServices(_ sender: UIButton) {
        //location
        //locationManager.requestWhenInUseAuthorization()
        
        //bluetooth
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        self.performSegue(withIdentifier: "toDetails", sender: nil)
    }
}

