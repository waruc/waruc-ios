//
//  ProfileViewController.swift
//  ios-app
//
//  Created by ishansaksena on 4/7/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit

class DriveViewController: UIViewController {
    
    // MARK: References
    //Main header
    @IBOutlet weak var cityHeader: UILabel!
    
    //Pairing area
    @IBOutlet weak var connectionTypeHeader: UILabel!
    @IBOutlet weak var connectionTypeSubHeader: UILabel!
    @IBOutlet weak var connectionImage: UIImageView!
    @IBOutlet weak var greyBoxOne: UILabel!

    //Vehicle area
    @IBOutlet weak var vehicleHeader: UILabel!
    @IBOutlet weak var vehicleSubHeader: UILabel!
    @IBOutlet weak var vehicleImage: UIImageView!
    @IBOutlet weak var greyBoxTwo: UILabel!
    
    //Bottom tracking bar
    @IBOutlet weak var bottomTrackingStatus: UILabel!
    @IBOutlet weak var bottomStartStopTrackingButton: UIButton!
    @IBOutlet weak var bottomBar: UIView!

    //Colors
    var purple = UIColor(red:0.58, green:0.11, blue:1.00, alpha:1.0)
    var black = UIColor(red:0.00, green:0.00, blue:0.00, alpha:1.0)
    var green = UIColor(red:0.22, green:0.78, blue:0.51, alpha:1.0)
    var backgroundBlack = UIColor(red:0.13, green:0.13, blue:0.15, alpha:1.0)
    var white = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
    var lightGrey = UIColor(red:0.61, green:0.61, blue:0.61, alpha:1.0)
    var darkGrey = UIColor(red:0.61, green:0.61, blue:0.61, alpha:1.0)
    
    // MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        /* TODO: Get user data */
        
        self.greyBoxOne.layer.cornerRadius = 6.0
        self.greyBoxOne.clipsToBounds = true
        self.greyBoxTwo.layer.cornerRadius = 6.0
        self.greyBoxTwo.clipsToBounds = true
        
        self.bottomBar.backgroundColor = green

    }
    
    var drive = false
    
    @IBAction func send(_ sender: UIButton) {
        if (!drive) {
            setBlack()
        } else {
            setWhite();
        }
        drive = !drive
    }
    
    func setBlack() {
        //bars
        self.bottomBar.backgroundColor = purple
        self.view.backgroundColor = backgroundBlack
        
        //grey images
        self.greyBoxOne.backgroundColor = darkGrey
        self.greyBoxTwo.backgroundColor = darkGrey
        
        
        //text
        self.cityHeader.textColor = white
        self.bottomTrackingStatus.text = "Tracking..."
        self.connectionTypeHeader.textColor = white
        self.vehicleHeader.textColor = white
        self.connectionTypeSubHeader.textColor = darkGrey
        self.vehicleSubHeader.textColor = darkGrey

    }
    
    func setWhite() {
        //bars
        self.bottomBar.backgroundColor = green
        self.view.backgroundColor = white
        
        //grey images
        self.greyBoxOne.backgroundColor = darkGrey
        self.greyBoxTwo.backgroundColor = darkGrey
        
        
        //text
        self.cityHeader.textColor = black
        self.bottomTrackingStatus.text = "Not Tracking"
        self.connectionTypeHeader.textColor = black
        self.vehicleHeader.textColor = black
        self.connectionTypeSubHeader.textColor = lightGrey
        self.vehicleSubHeader.textColor = lightGrey
    }

}
