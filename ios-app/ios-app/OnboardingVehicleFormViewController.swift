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

    override func viewDidLoad() {
        super.viewDidLoad()
        //BLERouter.sharedInstance.scan()
        
        DB.sharedInstance.fetchVehicleInfo(vin: "1G1JC5444R7252367")
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.displayInfo),
                                               name: DB.sharedInstance.fetchVehicleInfoNotification,
                                               object: nil)
        
//        form +++ Section("Account")
//            <<< TextRow() {
//                $0.title = "Make"
//                $0.value = DB.sharedInstance.currVehicleInfo["make"]
//                $0.disabled = true
//                $0.tag = "make"
//            }
//        
//            <<< TextRow() {
//                $0.title = "Model"
//                $0.disabled = true
//                $0.value = DB.sharedInstance.currVehicleInfo["model"]
//                $0.tag = "model"
//            }
//        
//            <<< TextRow() {
//                $0.title = "Year"
//                $0.disabled = true
//                $0.value = DB.sharedInstance.currVehicleInfo["year"]
//                $0.tag = "year"
//            }
//        
//            <<< TextRow() {
//                $0.title = "Nickname"
//                $0.disabled = false
//                $0.value = ""
//                $0.tag = "nickname"
//            }
//            .cellUpdate { cell, row in
//                DB.sharedInstance.currVehicleInfo["year"] = row.value
//            }
    }
    
    // Returns the nickname currently filled out
    func getNickname() {
    
    }
    
    func displayInfo() {        
        form +++ Section("Account")
            <<< TextRow() {
                $0.title = "Make"
                $0.value = DB.sharedInstance.fetchVehicleInfo["make"]
                $0.disabled = true
                $0.tag = "make"
            }
            
            <<< TextRow() {
                $0.title = "Model"
                $0.disabled = true
                $0.value = DB.sharedInstance.fetchVehicleInfo["model"]
                $0.tag = "model"
            }
            
            <<< TextRow() {
                $0.title = "Year"
                $0.disabled = true
                $0.value = DB.sharedInstance.fetchVehicleInfo["year"]
                $0.tag = "year"
            }
            
            <<< TextRow() {
                $0.title = "Nickname"
                $0.disabled = false
                $0.value = ""
                $0.tag = "nickname"
                }
                .cellUpdate { cell, row in
                    DB.sharedInstance.currVehicleInfo["year"] = row.value
        }
    }
}
