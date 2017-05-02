//
//  TripsViewController.swift
//  ios-app
//
//  Created by ishansaksena on 4/30/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit

class TripsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var tripTableView: UITableView!
    
    var green = UIColor(red:0.22, green:0.78, blue:0.51, alpha:1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bottomBar.backgroundColor = green
        
        // Table view setup 
        tripTableView.delegate = self
        tripTableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tripTableView.dequeueReusableCell(withIdentifier: "tripCell", for: indexPath) as! TripTableViewCell
        
        cell.dateLabel?.text = "This be the date"
        cell.timeLabel?.text = "This be the time"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
