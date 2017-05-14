//
//  VehicleRegistrationViewController.swift
//  ios-app
//
//  Created by Babbs, Dylan on 5/5/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit

class VehicleRegistrationViewController: UIViewController {
    
    //Labels
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var vehicleNicknameLabel: UILabel!
    
    //Fields
    @IBOutlet weak var brandField: UITextField!
    @IBOutlet weak var modelField: UITextField!
    @IBOutlet weak var yearField: UITextField!
    @IBOutlet weak var vehicleNicknameField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func next(_ sender: UIButton) {
        
    }
    
    @IBAction func later(_ sender: UIButton) {
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
