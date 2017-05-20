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

        form +++ Section("Account")
            <<< TextRow() {
                $0.title = "Car1"
                $0.disabled = true
                $0.value = "Car Value"
            }
        
            <<< TextRow() {
                $0.title = "Car2"
                $0.disabled = true
                $0.value = "Car Value"
            }
        
            <<< TextRow() {
                $0.title = "Car3"
                $0.disabled = true
                $0.value = "Car Value"
            }
        
            <<< TextRow() {
                $0.title = "Car4"
                $0.disabled = false
                $0.value = "Car Value"
            }
    }
}
