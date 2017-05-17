//
//  WARUCInfoViewController.swift
//  ios-app
//
//  Created by Babbs, Dylan on 5/16/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit

class WARUCInfoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func next(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toChecklist", sender: self)
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
