//
//  OnboardingVehicleFormViewController.swift
//  ios-app
//
//  Created by ishansaksena on 5/20/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit
import Eureka

class OnboardingVehicleFormViewController: FormViewController {

    let progressHUD = ProgressHUD(text: "Loading")
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DB.sharedInstance.getUserVehicles()
        
        self.view.addSubview(progressHUD)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.startBLEScan),
                                               name: BLERouter.sharedInstance.sharedInstanceReadyNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.displayInfo),
                                               name: DB.sharedInstance.newVehicleInfoNotification,
                                               object: nil)
    }
    
    func startBLEScan() {
        BLERouter.sharedInstance.scan()
    }
    
    func displayInfo() {
        NotificationCenter.default.removeObserver(self, name: DB.sharedInstance.newVehicleInfoNotification, object: nil)
        progressHUD.hide()
        form +++ Section("Account")
            <<< TextRow() {
                $0.title = "Make"
                $0.value = DB.sharedInstance.currVehicleInfo!["make"]
                $0.disabled = true
                $0.tag = "make"
            }
            
            <<< TextRow() {
                $0.title = "Model"
                $0.disabled = true
                $0.value = DB.sharedInstance.currVehicleInfo!["model"]
                $0.tag = "model"
            }
            
            <<< TextRow() {
                $0.title = "Year"
                $0.disabled = true
                $0.value = DB.sharedInstance.currVehicleInfo!["year"]
                $0.tag = "year"
            }
            
            <<< TextRow("Nickname") {
                $0.title = "Nickname"
                $0.disabled = DB.sharedInstance.currVehicleInfo!["nickname"] == nil ? false : true
                $0.value = DB.sharedInstance.currVehicleInfo!["nickname"] ?? ""
                $0.tag = "nickname"
            }
            .cellUpdate { cell, row in
                DB.sharedInstance.currVehicleInfo!["nickname"] = row.value
            }
    }
}
