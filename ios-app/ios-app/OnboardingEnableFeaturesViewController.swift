//
//  OnboardingEnableFeaturesViewController.swift
//  ios-app
//
//  Created by Babbs, Dylan on 5/20/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreLocation

class OnboardingEnableFeaturesViewController: UIViewController, CLLocationManagerDelegate, CBCentralManagerDelegate, CBPeripheralDelegate {

    
    

    
    //location
    var locationManager: CLLocationManager = CLLocationManager()
    var startLocation: CLLocation!
    
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!

    @IBOutlet weak var okayButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.okayButton.layer.cornerRadius = 4
        okayButton.clipsToBounds = true
        
        self.navigationController?.navigationBar.tintColor = Colors.green

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
    
    @available(iOS 5.0, *)
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("hi")
    }
    
    @IBAction func enableServices(_ sender: UIButton) {
        //location
        locationManager.requestWhenInUseAuthorization()
        
        //bluetooth
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        self.performSegue(withIdentifier: "toDetails", sender: nil)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

