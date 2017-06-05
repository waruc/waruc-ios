//
//  VehicleFilterViewController.swift
//  ios-app
//
//  Created by Nicholas Nordale on 6/4/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import Foundation
import UIKit

class VehicleFilterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var vehiclePickerView: UIPickerView!
    
    let tripFilterNotificationIdentifier = Notification.Name("tripFilterNotificationIdentifier")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.vehiclePickerView.delegate = self
        self.vehiclePickerView.dataSource = self
        
        vehiclePickerView.selectRow(DB.sharedInstance.tripsTableSelectedRow, inComponent: 0, animated: true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return DB.sharedInstance.userVehicles.count + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var selectedVehicle:[String: String]?
        if row == 0 {
            selectedVehicle = nil
        } else {
            selectedVehicle = Array(DB.sharedInstance.userVehicles.values)[row - 1]
        }
        NotificationCenter.default.post(name: tripFilterNotificationIdentifier, object: selectedVehicle)
        DB.sharedInstance.tripsTableSelectedRow = row
        self.dismiss(animated: true, completion: nil)
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.lineBreakMode = .byWordWrapping
        pickerLabel.numberOfLines = 0
        pickerLabel.sizeToFit()
        pickerLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        pickerLabel.font = UIFont.systemFont(ofSize: 20)
        pickerLabel.textAlignment = NSTextAlignment.center
        
        pickerView.isUserInteractionEnabled = true
        
        if row == 0 {
            pickerLabel.text = "All"
        } else {
            let rowVehicle = Array(DB.sharedInstance.userVehicles.values)[row - 1]
            pickerLabel.text = "\((rowVehicle["nickname"] ?? "").isEmpty ? "" : "\(rowVehicle["nickname"]!) - ")\(rowVehicle["year"]!) \(rowVehicle["make"]!) \(rowVehicle["model"]!)"
        }
        
        return pickerLabel
    }

}
