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
            
        BLERouter.sharedInstance.scan()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.displayInfo),
                                               name: DB.sharedInstance.newVehicleInfoNotification,
                                               object: nil)
    }
    
    // Returns the nickname currently filled out
    func getNickname() {
    
    }
    
    func displayInfo() { 
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
                $0.disabled = false
                $0.value = ""
                $0.tag = "nickname"
                }
                .cellUpdate { cell, row in
                    DB.sharedInstance.currVehicleInfo!["year"] = row.value
            }
            
            +++ Section("Submit")
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                    row.title = "Done"
                }
                .cellSetup() { cell, row in
                    cell.backgroundColor = UIColor.clear
                }
                .onCellSelection { [weak self] (cell, row) in
                    print("Creating vehicle")
                    let row: TextRow? = self?.form.rowBy(tag: "Nickname")
                    DB.sharedInstance.registerVehicle(nickname: row?.value)
        }
    }
}
