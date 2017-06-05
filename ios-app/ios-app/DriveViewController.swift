//
//  DriveViewController.swift
//  ios-app
//
//  Created by ishansaksena on 4/7/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Charts
import AudioToolbox


class DriveViewController: UIViewController {
    //Main header
    @IBOutlet weak var cityHeader: UILabel!
    @IBOutlet weak var locationIcon: UIImageView!
    
    //Pairing area
    @IBOutlet weak var connectionTypeHeader: UILabel!
    @IBOutlet weak var connectionTypeSubHeader: UILabel!
    @IBOutlet weak var greyBoxOne: UILabel!
    @IBOutlet weak var connectionTypeLogo: UIImageView!
    
    //Vehicle area
    @IBOutlet weak var vehicleHeader: UILabel!
    @IBOutlet weak var vehicleSubHeader: UILabel!
    @IBOutlet weak var greyBoxTwo: UILabel!
    @IBOutlet weak var vehicleMakeLogo: UIImageView!
    
    //Bottom tracking bar
    @IBOutlet weak var bottomTrackingStatus: UILabel!
    @IBOutlet weak var bottomStartStopTrackingButton: UIButton!
    @IBOutlet weak var bottomBar: UIView!
    
    @IBOutlet weak var animationView: UIView!
    
    var searchingAnimation: NVActivityIndicatorView?
    
    @IBOutlet weak var connectionHeaderTop: NSLayoutConstraint!
    @IBOutlet weak var vehicleHeaderTop: NSLayoutConstraint!
    
    //Charts
    @IBOutlet weak var currentMPH: UILabel!
    @IBOutlet weak var mphLabel: UILabel!
    @IBOutlet weak var lineChart: LineChartView!
    
    var initialGraph = true
    
    // MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cityHeader.text = "Drive"
        locationIcon.isHidden = true
        
        searchingAnimation = NVActivityIndicatorView(frame: CGRect(x: 10, y: 10, width: 32, height: 32))
        searchingAnimation!.color = UIColor.black
        //searchingAnimation = .ballScaleRippleMultiple
        searchingAnimation!.startAnimating()
        self.animationView.addSubview(searchingAnimation!)
        
        self.greyBoxOne.layer.cornerRadius = 6.0
        self.greyBoxOne.clipsToBounds = true
        self.greyBoxTwo.layer.cornerRadius = 6.0
        self.greyBoxTwo.clipsToBounds = true
        
        self.bottomBar.backgroundColor = Colors.green

        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.updateConnection),
                                               name: BLERouter.sharedInstance.connectionTypeNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.displayConnectionStrength),
                                               name: BLERouter.sharedInstance.connectionStrengthNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.updateColorScheme),
                                               name: BLERouter.sharedInstance.colorUpdateNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.updateVehicleInfo),
                                               name: DB.sharedInstance.existingVehicleInfoNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self, 
                                               selector: #selector(self.updateCityHeader(_:)), 
                                               name: Notification.Name("cityHeaderNotification"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self, 
                                               selector: #selector(self.updateLocationIcon(_:)), 
                                               name: Notification.Name("locationIconNotification"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.updateLocationConnection(_:)),
                                               name: Notification.Name("LocationConnectionUpdateNotificatonIdentifier"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.updateMPH(_:)),
                                               name: BLERouter.sharedInstance.mphUpdateNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.updateChart),
                                               name: BLERouter.sharedInstance.graphUpdateNotification,
                                               object: nil)
        
        if BLERouter.sharedInstance.connectionType != nil {
            updateConnection()
        }
        
        if BLERouter.sharedInstance.bleConnectionStrength != nil {
            displayConnectionStrength()
        }
        
        if DB.sharedInstance.currVehicleInfo != nil &&
            DB.sharedInstance.currVehicleInfo!["vin"] != nil &&
            DB.sharedInstance.userVehicles.keys.contains(DB.sharedInstance.currVehicleInfo!["vin"]!) {
            updateVehicleInfo()
        }
        
    }
     
    func updateCityHeader(_ notification: NSNotification) {
        if let text = notification.userInfo?["text"] as? String {
            self.cityHeader.text = text  
        }
    }
    
    func updateLocationIcon(_ notification: NSNotification) {
        if let status = notification.userInfo?["status"] as? Bool {
            self.locationIcon.isHidden = status 
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        if BLERouter.sharedInstance.tracking || Location.sharedInstance.tracking {
            setBlack()
        } else {
            setWhite()
        }
        
        bottomStartStopTrackingButton.isHidden = true
        if UserDefaults.standard.value(forKey: "ble_tracking") == nil && UserDefaults.standard.value(forKey: "location_tracking") != nil {
            bottomStartStopTrackingButton.isHidden = false
            
            if DB.sharedInstance.currVehicleInfo == nil {
                bottomStartStopTrackingButton.isEnabled = false
            } else {
                bottomStartStopTrackingButton.isEnabled = true
            }
        }
        
        currentMPH.text = "0"
        initialGraph = true
    }

    
    @IBAction public func send(_ sender: UIButton) {
        BLERouter.sharedInstance.tracking = !BLERouter.sharedInstance.tracking
        Location.sharedInstance.tracking = !Location.sharedInstance.tracking
        
        updateColorScheme()
        
        if Location.sharedInstance.tracking {
            Location.sharedInstance.startTracking()
        } else {
            Location.sharedInstance.stopTracking()
        }
    }
    
    func updateColorScheme() {
        if BLERouter.sharedInstance.tracking || Location.sharedInstance.tracking {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate)) 
            setBlack()
        } else {
            setWhite()
        }
    }
    
    func setBlack() {
        //charts
        lineChart.isHidden = false
        currentMPH.isHidden = false
        mphLabel.isHidden = false
        updateChart()
        
        //bars
        self.bottomBar.backgroundColor = Colors.purple
        self.view.backgroundColor = Colors.backgroundBlack

        //grey images
        self.greyBoxOne.backgroundColor = Colors.darkGrey
        self.greyBoxTwo.backgroundColor = Colors.darkGrey
        
        //text
        self.cityHeader.textColor = Colors.white
        self.bottomTrackingStatus.text = "Tracking..."

        self.searchingAnimation!.color = UIColor.white
        if self.searchingAnimation!.animating {
            self.searchingAnimation!.startAnimating()
        }
        self.connectionTypeHeader.textColor = Colors.white
        self.vehicleHeader.textColor = Colors.white
        self.connectionTypeSubHeader.textColor = Colors.darkGrey
        self.vehicleSubHeader.textColor = Colors.darkGrey
        
        //button
        bottomStartStopTrackingButton.setTitle("Stop", for: .normal)
        
        //Tab Bar
        self.tabBarController?.tabBar.backgroundColor = Colors.backgroundBlack
        self.tabBarController?.tabBar.barTintColor = Colors.backgroundBlack
        
        //Status bar
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
        
        //Transitions
        transition(item: self.view)
        transition(item: (self.tabBarController?.tabBar)!)
    }
    
    func setWhite() {
        //charts
        lineChart.isHidden = true
        currentMPH.isHidden = true
        mphLabel.isHidden = true
        
        //bars
        self.bottomBar.backgroundColor = Colors.green
        self.view.backgroundColor = Colors.white
        
        //grey images
        self.greyBoxOne.backgroundColor = Colors.lightGrey
        self.greyBoxTwo.backgroundColor = Colors.lightGrey
        
        //text
        self.cityHeader.textColor = Colors.black
        self.bottomTrackingStatus.text = "Not Tracking"
        
        self.searchingAnimation!.color = UIColor.black
        if self.searchingAnimation!.animating {
            self.searchingAnimation!.startAnimating()
        }
        self.connectionTypeHeader.textColor = Colors.black
        self.vehicleHeader.textColor = Colors.black
        self.connectionTypeSubHeader.textColor = Colors.darkGrey
        self.vehicleSubHeader.textColor = Colors.darkGrey
        
        //button
        bottomStartStopTrackingButton.setTitle("Start", for: .normal)
        
        //Tab bar
        self.tabBarController?.tabBar.backgroundColor = UIColor.white
        self.tabBarController?.tabBar.barTintColor = UIColor.white
        
        //Status bar
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.default, animated: true)
        
        lineChart.isHidden = true;
        
        //Transitions
        transition(item: self.view)
        transition(item: (self.tabBarController?.tabBar)!)
    }
    
    func transition(item: UIView) {
        UIView.transition(with: item,
                          duration: Colors.transitionTime,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
    }
    
    //******** BLE **********
    func updateConnection() {
        if BLERouter.sharedInstance.connectionType != nil {
            connectionTypeLogo.image = #imageLiteral(resourceName: "bluetooth")
            searchingAnimation?.stopAnimating()
            
            connectionHeaderTop.constant -= 12
            connectionTypeHeader.text = BLERouter.sharedInstance.connectionType
        } else {
            connectionTypeLogo.image = nil
            connectionTypeSubHeader.text = ""
            searchingAnimation?.startAnimating()
            connectionHeaderTop.constant += 12
            connectionTypeHeader.text = "Searching"
        }
    }
    
    func displayConnectionStrength() {
        connectionTypeSubHeader.text = BLERouter.sharedInstance.bleConnectionStrength!
    }
    
    func updateVehicleInfo() {
        if DB.sharedInstance.currVehicleInfo != nil {
            bottomStartStopTrackingButton.isEnabled = true
            vehicleMakeLogo.image = UIImage(named: "\(DB.sharedInstance.currVehicleInfo!["make"]!.lowercased())_logo")
            vehicleHeaderTop.constant -= 12
            if (DB.sharedInstance.currVehicleInfo!["nickname"] ?? "").isEmpty {
                vehicleHeader.text = "\(DB.sharedInstance.currVehicleInfo!["make"]!.capitalized)"
                vehicleSubHeader.text = "\(DB.sharedInstance.currVehicleInfo!["year"]!) \(DB.sharedInstance.currVehicleInfo!["model"]!)"
            } else {
                vehicleHeader.text = "\(DB.sharedInstance.currVehicleInfo!["nickname"]!)"
                vehicleSubHeader.text = "\(DB.sharedInstance.currVehicleInfo!["year"]!) \(DB.sharedInstance.currVehicleInfo!["make"]!.capitalized) \(DB.sharedInstance.currVehicleInfo!["model"]!)"
            }
        } else {
            vehicleMakeLogo.image = nil
            vehicleHeaderTop.constant += 12
            vehicleHeader.text = "Vehicle not connected"
            vehicleSubHeader.text = ""
        }
    }
    
    func updateMPH(_ notification: NSNotification) {
        if let data = (notification.object as? [String: Double]) {
            currentMPH.text = "\(Int(data["speed"]!.rounded(.toNearestOrAwayFromZero)))"
            currentMPH.sizeToFit()
        }
    }
    
    //******** Location **********
    func updateLocationConnection(_ notification: Notification) {
        if notification.object == nil {
            connectionTypeLogo.image = nil
            connectionTypeSubHeader.text = ""
            searchingAnimation?.startAnimating()
            connectionTypeHeader.text = "Searching"
        } else {
            if let connection = (notification.object as? [String: String]) {
                connectionTypeLogo.image = #imageLiteral(resourceName: "navigation")
                searchingAnimation?.stopAnimating()
                connectionTypeHeader.text = connection["connection"]
            }
        }
    }
    
    //******** Charts *******
    func updateChart() {
        if UserDefaults.standard.value(forKey: "ble_tracking") != nil || UserDefaults.standard.value(forKey: "location_tracking") != nil {
            var y = UserDefaults.standard.value(forKey: "ble_tracking") != nil ? BLERouter.sharedInstance.graphSpeeds : Location.sharedInstance.graphSpeeds
            y += [Double](repeating: 0.0, count: 10 - y.count)
            
            var dataEntries: [ChartDataEntry] = []
            for i in 0..<y.count {
                let dataEntry = ChartDataEntry(x: Double(i), y: Double(y[i]))
                dataEntries.append(dataEntry)
            }
            
            let lineChartDataSet = LineChartDataSet(values: dataEntries, label: "Example Chart")
            lineChartDataSet.mode = .cubicBezier
            lineChart.data = LineChartData(dataSet: lineChartDataSet)
            
            //set colors
            lineChart.backgroundColor = UIColor(white: 1, alpha: 0)
            let gradientColors = [Colors.lightBlue.cgColor, Colors.lighterBlue.cgColor] as CFArray
            let colorLocations: [CGFloat] = [1.0, 0.2]
            guard let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) else {
                print("gradient"); return
            }
            lineChartDataSet.fill = Fill.fillWithLinearGradient(gradient, angle: 90)
            lineChartDataSet.drawFilledEnabled = true
            lineChartDataSet.drawCircleHoleEnabled = false
            lineChartDataSet.circleRadius = 0
            
            //animation
            if initialGraph {
                lineChart.animate(xAxisDuration: 0.0, yAxisDuration: 1.5)
                initialGraph = false
            }
            
            //remove axis and gridlines
            lineChart.xAxis.drawGridLinesEnabled = false
            lineChart.xAxis.drawAxisLineEnabled = false
            lineChart.leftAxis.drawGridLinesEnabled = false
            lineChart.leftAxis.drawAxisLineEnabled = false
            lineChart.rightAxis.drawGridLinesEnabled = false
            lineChart.rightAxis.drawAxisLineEnabled = false
            
            //remove text
            lineChart.data?.setDrawValues(false)
            lineChart.xAxis.drawLabelsEnabled = false
            lineChart.leftAxis.drawLabelsEnabled = false
            lineChart.rightAxis.drawLabelsEnabled = false
            lineChart.legend.enabled = false
            lineChart.chartDescription?.text = ""
            
            lineChart.isUserInteractionEnabled = false
        }
    }
    
}
