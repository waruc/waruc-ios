//
//  FormViewController.swift
//  tabletest
//
//  Created by ishansaksena on 5/13/17.
//  Copyright © 2017 ishansaksena. All rights reserved.
//

import Eureka
import FirebaseAuth
import MessageUI


class SettingsFormViewController: FormViewController, MFMailComposeViewControllerDelegate {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addNewVehicle" {
            if let toViewController = segue.destination as? OnboardingVehicleInputFrameViewController {
                toViewController.hideSkip = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form
            +++ Section("Vehicles")
            
                <<< PickerInlineRow<String>("Current Car") { (row : PickerInlineRow<String>) -> Void in
                    row.title = row.tag
                    row.displayValueFor = { (rowValue: String?) in
                        return rowValue
                    }
                    row.options = ["BMW 725i", "Hummer H2", "Ferrari 458 Italia"]
                    row.value = row.options[0]
                    }.cellSetup() {cell, row in
                        cell.backgroundColor = Colors.backgroundBlack
                        cell.tintColor = UIColor.white
                        cell.textLabel?.textColor = UIColor.white
                }
            
                <<< ButtonRow("Add New Vehicle") {
                    $0.title = "Add New Vehicle"
                    }
                    .onCellSelection {  cell, row in  //sign out
                        self.performSegue(withIdentifier: "addNewVehicle", sender: self)
                        self.navigationController?.setNavigationBarHidden(false, animated: true)
                    }
            
//            +++ Section(header: "Tracking Type", footer: "In-vehicle tracking requires the use of an OBD-II port. Location tracking involves the use of your device's GPS.")
//
//                <<< PickerInlineRow<String>("Tracking Option") { (row : PickerInlineRow<String>) -> Void in
//                    row.title = row.tag
//                    row.displayValueFor = { (rowValue: String?) in
//                        return rowValue
//                    }
//                    row.options = ["In-vehicle tracking", "Location Tracking"]
//                    row.value = row.options[0]
//                }
            
            
//            +++ Section(header: "Account", footer: "The password must be at least 8 characters long")
            +++ Section("Account")
            
//                <<< TextRow(){ row in
//                    row.title = "Name"
//                    row.placeholder = "First Last"
//                }
            
                <<< TextRow("Email") {
                    $0.title = "Email"
                    $0.add(rule: RuleRequired())
                    var ruleSet = RuleSet<String>()
                    ruleSet.add(rule: RuleRequired())
                    ruleSet.add(rule: RuleEmail())
                    $0.add(ruleSet: ruleSet)
                    $0.validationOptions = .validatesOnChangeAfterBlurred
                    $0.placeholder = "example@email.com"
                    $0.value = FIRAuth.auth()?.currentUser?.email!
                    $0.disabled = true
                    }
                    .cellUpdate { cell, row in
                        if !row.isValid {
                            cell.titleLabel?.textColor = .red
                        }
                }
            
            
//                <<< PasswordRow() {
//                    $0.title = "Password"
//                    $0.add(rule: RuleMinLength(minLength: 8))
//                    //$0.add(rule: RuleMaxLength(maxLength: 13))
//                    }
//                    .cellUpdate { cell, row in
//                        if !row.isValid {
//                            cell.titleLabel?.textColor = .red
//                        }
//                }
            
//                <<< ButtonRow() { 
//                        $0.title = "Sign out"
//                    }
//                    .onCellSelection {  cell, row in  //sign out
//                        try! FIRAuth.auth()!.signOut()
//                        self.performSegue(withIdentifier: "signOut", sender: self)
//                }
            
            
            +++ Section(header: "About", footer: "© 2017 Dylan Babbs, Jackson Brown, Jack Fox, Nick Nordale, and Ishan Saksena. All rights reserved.    ")
            
//                //TODO: reinsert when website is running
//                <<< ButtonRow("About the App") {
//                    $0.title = $0.tag
//                    $0.presentationMode = .segueName(segueName: "aboutApp", onDismiss: nil)
//                }
            
                <<< ButtonRow("About the Program") {
                    $0.title = $0.tag
                    $0.presentationMode = .segueName(segueName: "aboutProgram", onDismiss: nil)
                } 
                
                <<< ButtonRow("Privacy Policy") {
                    $0.title = $0.tag
                    $0.presentationMode = .segueName(segueName: "privacyPolicy", onDismiss: nil)
                }
            
//                <<< ButtonRow("Rate us in the App Store") {
//                    $0.title = $0.tag
//                    }
//                    .onCellSelection { cell, row in 
//                        
//                        self.rateApp(appId: "id389801252") { success in
//                            print("RateApp \(success)")
//                        }
//                }
            
                <<< ButtonRow("Report an Issue") {
                    $0.title = $0.tag
                    
                    }
                    .onCellSelection { cell, row in 
                        self.sendEmail()
                }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        if BLERouter.sharedInstance.tracking {
            setBlack()
        } else {
            setWhite()
        }
    }
    
    func updateColorScheme() {
        if BLERouter.sharedInstance.tracking {
            setBlack()
        } else {
            setWhite()
        }
    }
    
    func setBlack() {
        self.tableView.backgroundColor = UIColor(red:0.14, green:0.13, blue:0.21, alpha:1.0)
        
        if let vehiclePickerRow:PickerInlineRow<String> = form.rowBy(tag: "Current Car") {
            vehiclePickerRow.cellUpdate { cell, row in
                cell.backgroundColor = UIColor(red:0.14, green:0.13, blue:0.21, alpha:1.0)
                cell.textLabel?.textColor = UIColor.white
                cell.detailTextLabel?.textColor = UIColor.white
            }
            
            vehiclePickerRow.updateCell()
        }
        
        if let addNewVehicleRow:ButtonRow = form.rowBy(tag: "Add New Vehicle") {
            addNewVehicleRow.cellUpdate { cell, row in
                cell.backgroundColor = UIColor(red:0.14, green:0.13, blue:0.21, alpha:1.0)
                cell.textLabel?.textColor = UIColor.white
                cell.detailTextLabel?.textColor = UIColor.white
            }
            
            addNewVehicleRow.updateCell()
        }
        
        if let emailRow:TextRow = form.rowBy(tag: "Email") {
            emailRow.cellUpdate { cell, row in
                cell.backgroundColor = UIColor(red:0.14, green:0.13, blue:0.21, alpha:1.0)
                cell.textLabel?.textColor = UIColor.white
                cell.detailTextLabel?.textColor = UIColor.white
            }
            
            emailRow.updateCell()
        }
        
        if let aboutTheProgramRow:ButtonRow = form.rowBy(tag: "About the Program") {
            aboutTheProgramRow.cellUpdate { cell, row in
                cell.backgroundColor = UIColor(red:0.14, green:0.13, blue:0.21, alpha:1.0)
                cell.textLabel?.textColor = UIColor.white
                cell.detailTextLabel?.textColor = UIColor.white
            }
            
            aboutTheProgramRow.updateCell()
        }
        
        if let privacyPolicyRow:ButtonRow = form.rowBy(tag: "Privacy Policy") {
            privacyPolicyRow.cellUpdate { cell, row in
                cell.backgroundColor = UIColor(red:0.14, green:0.13, blue:0.21, alpha:1.0)
                cell.textLabel?.textColor = UIColor.white
                cell.detailTextLabel?.textColor = UIColor.white
            }
            
            privacyPolicyRow.updateCell()
        }
        
        if let reportAnIssueRow:ButtonRow = form.rowBy(tag: "Report an Issue") {
            reportAnIssueRow.cellUpdate { cell, row in
                cell.backgroundColor = UIColor(red:0.14, green:0.13, blue:0.21, alpha:1.0)
                cell.textLabel?.textColor = UIColor.white
                cell.detailTextLabel?.textColor = UIColor.white
            }
            
            reportAnIssueRow.updateCell()
        }
        
        self.tableView.reloadData()
    }
    
    func setWhite() {
        self.tableView.backgroundColor = UIColor.white
        
        if let vehiclePickerRow:PickerInlineRow<String> = form.rowBy(tag: "Current Car") {
            vehiclePickerRow.cellUpdate { cell, row in
                cell.backgroundColor = UIColor.white
                cell.textLabel?.textColor = UIColor.black
                cell.detailTextLabel?.textColor = UIColor.black
            }
            
            vehiclePickerRow.updateCell()
        }
        
        if let addNewVehicleRow:ButtonRow = form.rowBy(tag: "Add New Vehicle") {
            addNewVehicleRow.cellUpdate { cell, row in
                cell.backgroundColor = UIColor.white
                cell.textLabel?.textColor = UIColor.black
                cell.detailTextLabel?.textColor = UIColor.black
            }
            
            addNewVehicleRow.updateCell()
        }
        
        if let emailRow:TextRow = form.rowBy(tag: "Email") {
            emailRow.cellUpdate { cell, row in
                cell.backgroundColor = UIColor.white
                cell.textLabel?.textColor = UIColor.black
                cell.detailTextLabel?.textColor = UIColor.black
            }
            
            emailRow.updateCell()
        }
        
        if let aboutTheProgramRow:ButtonRow = form.rowBy(tag: "About the Program") {
            aboutTheProgramRow.cellUpdate { cell, row in
                cell.backgroundColor = UIColor.white
                cell.textLabel?.textColor = UIColor.black
                cell.detailTextLabel?.textColor = UIColor.black
            }
            
            aboutTheProgramRow.updateCell()
        }
        
        if let privacyPolicyRow:ButtonRow = form.rowBy(tag: "Privacy Policy") {
            privacyPolicyRow.cellUpdate { cell, row in
                cell.backgroundColor = UIColor.white
                cell.textLabel?.textColor = UIColor.black
                cell.detailTextLabel?.textColor = UIColor.black
            }
            
            privacyPolicyRow.updateCell()
        }
        
        if let reportAnIssueRow:ButtonRow = form.rowBy(tag: "Report an Issue") {
            reportAnIssueRow.cellUpdate { cell, row in
                cell.backgroundColor = UIColor.white
                cell.textLabel?.textColor = UIColor.black
                cell.detailTextLabel?.textColor = UIColor.black
            }
            
            reportAnIssueRow.updateCell()
        }
    }
    
    func sendEmail() {      
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        // Configure the fields of the interface.
        composeVC.setToRecipients(["capstone.waruc@gmail.com"])
        composeVC.setSubject("WARUC App Bug")
        composeVC.setMessageBody("Hello, I've found an issue with the WARUC app.", isHTML: false)
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }

    func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/" + appId) else {
            completion(false)
            return
        }
        guard #available(iOS 10, *) else {
            completion(UIApplication.shared.openURL(url))
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }
    
}
