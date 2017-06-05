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
        
        self.view.addSubview(progressHUD)
        
        if DB.sharedInstance.currVehicleInfo != nil {
            displayInfo()
        } else {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.displayInfo),
                                                   name: DB.sharedInstance.newVehicleInfoNotification,
                                                   object: nil)
        }
    }
    
    func displayInfo() {
        NotificationCenter.default.removeObserver(self, name: DB.sharedInstance.newVehicleInfoNotification, object: nil)
        progressHUD.hide()
        form +++ Section("Account")
            <<< TextRow() {
                $0.title = "Make"
                $0.value = DB.sharedInstance.currVehicleInfo!["make"]
                $0.disabled = (DB.sharedInstance.currVehicleInfo!["make"] ?? "").isEmpty ? false : true
                $0.evaluateDisabled()
                $0.tag = "make"
            }
            .cellUpdate { cell, row in
                    DB.sharedInstance.currVehicleInfo!["make"] = row.value
            }
            
            <<< TextRow() {
                $0.title = "Model"
                $0.value = DB.sharedInstance.currVehicleInfo!["model"]
                $0.disabled = (DB.sharedInstance.currVehicleInfo!["model"] ?? "").isEmpty ? false : true
                $0.evaluateDisabled()
                $0.tag = "model"
            }
            .cellUpdate { cell, row in
                    DB.sharedInstance.currVehicleInfo!["model"] = row.value
            }
            
            <<< TextRow() {
                $0.title = "Year"
                $0.value = DB.sharedInstance.currVehicleInfo!["year"]
                $0.disabled = (DB.sharedInstance.currVehicleInfo!["year"] ?? "").isEmpty ? false : true
                $0.evaluateDisabled()
                $0.tag = "year"
            }
            .cellUpdate { cell, row in
                    DB.sharedInstance.currVehicleInfo!["year"] = row.value
            }
            
            <<< TextRow("Nickname") {
                $0.title = "Nickname"
                $0.value = DB.sharedInstance.currVehicleInfo!["nickname"]
                $0.disabled = (DB.sharedInstance.currVehicleInfo!["nickname"] ?? "").isEmpty ? false : true
                $0.evaluateDisabled()
                $0.tag = "nickname"
            }
            .cellUpdate { cell, row in
                DB.sharedInstance.currVehicleInfo!["nickname"] = row.value
            }
    }
}
