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

    @IBOutlet weak var okayButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.okayButton.layer.cornerRadius = CGFloat(Constants.round)
        okayButton.clipsToBounds = true
        
        self.navigationController?.navigationBar.tintColor = Colors.green
        
        let bleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(bleTapped(tapGestureRecognizer:)))
        bluetoothImage.isUserInteractionEnabled = true
        bluetoothImage.addGestureRecognizer(bleTapGestureRecognizer)
        
        let locationTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(locationTapped(tapGestureRecognizer:)))
        locationImage.isUserInteractionEnabled = true
        locationImage.addGestureRecognizer(locationTapGestureRecognizer)
    }
    
    func bleTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        UserDefaults.standard.setValue("ble", forKey: "tracking_method")
        print("Set user tracking method to: \(UserDefaults.standard.value(forKey: "tracking_method")!)")
        self.performSegue(withIdentifier: "setupOBD", sender: nil)
    }
    
    func locationTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        UserDefaults.standard.setValue("location", forKey: "tracking_method")
        print("Set user tracking method to: \(UserDefaults.standard.value(forKey: "tracking_method")!)")
        self.performSegue(withIdentifier: "finishLocationSetup", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
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

