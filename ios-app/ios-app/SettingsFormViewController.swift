//
//  FormViewController.swift
//  tabletest
//
//  Created by ishansaksena on 5/13/17.
//  Copyright © 2017 ishansaksena. All rights reserved.
//

import Eureka

class SettingsFormViewController: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section("Vehicles")
            
            <<< PickerInlineRow<String>("Current Car") { (row : PickerInlineRow<String>) -> Void in
                row.title = row.tag
                row.displayValueFor = { (rowValue: String?) in
                    return rowValue
                }
                row.options = ["BMW 725i", "Hummer H2", "Ferrari 458 Italia"]
                row.value = row.options[0]
            }
            
            +++ Section(header: "Account", footer: "The password must be at least 8 characters long")
            
            <<< TextRow(){ row in
                row.title = "Name"
                row.placeholder = "Rick Sanchez"
            }
            
            <<< TextRow() {
                $0.title = "Email"
                $0.add(rule: RuleRequired())
                var ruleSet = RuleSet<String>()
                ruleSet.add(rule: RuleRequired())
                ruleSet.add(rule: RuleEmail())
                $0.add(ruleSet: ruleSet)
                $0.validationOptions = .validatesOnChangeAfterBlurred
                $0.placeholder = "rick@getschwifty.com"
                }
                .cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
            }
            
            <<< PasswordRow() {
                $0.title = "Password"
                $0.add(rule: RuleMinLength(minLength: 8))
                //$0.add(rule: RuleMaxLength(maxLength: 13))
                }
                .cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
            }
            
            +++ Section(header: "Other", footer: "Options: Validates on change after blurred")
            
            <<< SegmentedRow<String>(){
                $0.title = "Units"
                $0.options = ["Kilometers", "Miles"]
                $0.value = "Miles"
            }
            
            <<< SwitchRow() {
                $0.title = "Location Tracking"
                $0.value = true
        }
        
    }
}
