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
            <<< TextRow(){ row in
                row.title = "Add New Vehicle"
                row.placeholder = "Vehicle Name"
            }
            
            +++ Section(header: "Tracking Type", footer: "In-vehicle tracking requires the use of an OBD-II port. Location tracking involves the use of your device's GPS.")
            
            <<< PickerInlineRow<String>("Tracking Option") { (row : PickerInlineRow<String>) -> Void in
                row.title = row.tag
                row.displayValueFor = { (rowValue: String?) in
                    return rowValue
                }
                row.options = ["In-vehicle tracking", "Location Tracking"]
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
            
            <<< ButtonRow() { 
                    $0.title = "Sign out"
                }
                .onCellSelection {  cell, row in  //sign out
            }
                    
            
            +++ Section(header: "About", footer: "© 2017 Dylan Babbs, Jackson Brown, Jack Fox, Nick Nordale, and Ishan Saksena. All rights reserved.    ")
            

            
            //This doesn't work yet
            <<< ButtonRow("About the App") {
                $0.title = $0.tag
                $0.presentationMode = .segueName(segueName: "about", onDismiss: nil)
            } 
            <<< ButtonRow("About the Program") {
                $0.title = $0.tag
                $0.presentationMode = .segueName(segueName: "about", onDismiss: nil)
            } 
            <<< ButtonRow("Report an Issue") {
                $0.title = $0.tag
                $0.presentationMode = .segueName(segueName: "about", onDismiss: nil)
            }
            <<< ButtonRow("Rate us in the App Store") {
                $0.title = $0.tag
                $0.presentationMode = .segueName(segueName: "about", onDismiss: nil)
                //itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=YOUR_APP_ID&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software

            }
            <<< ButtonRow("Privacy Policy") {
                $0.title = $0.tag
                $0.presentationMode = .segueName(segueName: "about", onDismiss: nil)
            } 
        
    }
}
