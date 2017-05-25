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
        form +++ Section("Vehicles")
            
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
            
            <<< ButtonRow() { 
                $0.title = "Add New Vehicle"
                }
                .onCellSelection {  cell, row in  //sign out
                    self.performSegue(withIdentifier: "addNewVehicle", sender: self)
                    self.navigationController?.setNavigationBarHidden(false, animated: true)
                }
            
            //Removed for apple setup
//            +++ Section(header: "Tracking Type", footer: "In-vehicle tracking requires the use of an OBD-II port. Location tracking involves the use of your device's GPS.")
//            
//            <<< PickerInlineRow<String>("Tracking Option") { (row : PickerInlineRow<String>) -> Void in
//                row.title = row.tag
//                row.displayValueFor = { (rowValue: String?) in
//                    return rowValue
//                }
//                row.options = ["In-vehicle tracking", "Location Tracking"]
//                row.value = row.options[0]
//            }
            
            
            +++ Section(header: "Account", footer: "The password must be at least 8 characters long")
            
            <<< TextRow(){ row in
                row.title = "Name"
                row.placeholder = "John Smith"
            }
            
            <<< TextRow() {
                $0.title = "Email"
                $0.add(rule: RuleRequired())
                var ruleSet = RuleSet<String>()
                ruleSet.add(rule: RuleRequired())
                ruleSet.add(rule: RuleEmail())
                $0.add(ruleSet: ruleSet)
                $0.validationOptions = .validatesOnChangeAfterBlurred
                $0.placeholder = "example@email.com"
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
                    try! FIRAuth.auth()!.signOut()
                    self.performSegue(withIdentifier: "signOut", sender: self)
            }
                    
            
            +++ Section(header: "About", footer: "© 2017 Dylan Babbs, Jackson Brown, Jack Fox, Nick Nordale, and Ishan Saksena. All rights reserved.    ")
            
            //TODO: reinsert when website is running
//            <<< ButtonRow("About the App") {
//                $0.title = $0.tag
//                $0.presentationMode = .segueName(segueName: "aboutApp", onDismiss: nil)
//            } 
            <<< ButtonRow("About the Program") {
                $0.title = $0.tag
                $0.presentationMode = .segueName(segueName: "aboutProgram", onDismiss: nil)
            } 
            
            <<< ButtonRow("Privacy Policy") {
                $0.title = $0.tag
                $0.presentationMode = .segueName(segueName: "privacyPolicy", onDismiss: nil)
            } 
            //delete this until second app store submission
            //TODO: reinsert for second app store submission
//            <<< ButtonRow("Rate us in the App Store") {
//                $0.title = $0.tag
//                }
//                .onCellSelection { cell, row in 
//                    
//                    self.rateApp(appId: "id389801252") { success in
//                        print("RateApp \(success)")
//                    }
//            }
            <<< ButtonRow("Report an Issue") {
                $0.title = $0.tag
                
                }
                .onCellSelection { cell, row in 
                    self.sendEmail()
            }
    }

    
    override func viewWillAppear(_ animated: Bool) {
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
        print("set black occurred")
        TextRow.defaultCellUpdate = { cell, row in 
            cell.backgroundColor = Colors.backgroundBlack
        }
        ButtonRow.defaultCellUpdate = { cell, row in 
            cell.backgroundColor = Colors.backgroundBlack
        }
        PasswordRow.defaultCellUpdate = { cell, row in 
            cell.backgroundColor = Colors.backgroundBlack
        }
        PickerInlineRow<String>.defaultCellUpdate = { cell, row in 
            cell.backgroundColor = Colors.backgroundBlack
        }
        self.tableView?.backgroundColor = UIColor(red:0.14, green:0.13, blue:0.21, alpha:1.0)
    }
    
    func setWhite() {
        self.tableView?.backgroundColor = Colors.tableGrey
        TextRow.defaultCellUpdate = { cell, row in 
            cell.backgroundColor = Colors.white
        }
        ButtonRow.defaultCellUpdate = { cell, row in 
            cell.backgroundColor = Colors.white
        }
        PasswordRow.defaultCellUpdate = { cell, row in 
            cell.backgroundColor = Colors.white
        }
        PickerInlineRow<String>.defaultCellUpdate = { cell, row in 
            cell.backgroundColor = Colors.white
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
