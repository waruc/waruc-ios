//
//  ProfileViewController.swift
//  ios-app
//
//  Created by ishansaksena on 4/7/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import NVActivityIndicatorView
import Charts
import RealmSwift

class DriveViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: References
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
    
    //Location
    var locationManager = CLLocationManager()
    var startLocation: CLLocation!
    
    
    // MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //cityHeader.text = "Drive"
        locationIcon.isHidden = true
        
        //bottomStartStopTrackingButton.isHidden = true
        
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
        locationIcon.isHidden = true
        
        //Location services:
        locationManager = CLLocationManager()

        
        
        location()
        
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
        
        if BLERouter.sharedInstance.connectionType != nil {
            updateConnection()
        }
        
        if BLERouter.sharedInstance.bleConnectionStrength != nil {
            displayConnectionStrength()
        }
        
        if DB.sharedInstance.currVehicleInfo != nil &&
            DB.sharedInstance.userVehicles.keys.contains(DB.sharedInstance.currVehicleInfo!["vin"]!) {
            updateVehicleInfo()
        }
        
        view.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        if BLERouter.sharedInstance.tracking {
            setBlack()
        } else {
            setWhite()
        }
    }
    
    @IBAction public func send(_ sender: UIButton) {
        BLERouter.sharedInstance.tracking = !BLERouter.sharedInstance.tracking
        updateColorScheme()
    }
    
    func updateColorScheme() {
        if BLERouter.sharedInstance.tracking {
            setBlack()
            startTracking()
        } else {
            setWhite()
            stopTracking()
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
    
    //******** Charts *******

    func updateChart() {
        //Data
        var y:[Double] = [3.0, 8.0, 7.0, 11.0, 13.0, 17.0, 12.0, 9.0, 15.0, 8.0, 10.0]
        
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
        lineChart.animate(xAxisDuration: 0.0, yAxisDuration: 1.5)
        
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

    }
    
    
    
    
    func location() {
        //locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        // OR
        //locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        // OR
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    
        //Below changes meter interval to update location
        locationManager.distanceFilter = 25
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        startLocation = nil
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // App may no longer be authorized to obtain location
        //information. Check status here and respond accordingly
    }
    
    //**** tracking ****
    
    var tracking = false
    var trackStartTimeStamp : Date? = nil
    var path = GMSMutablePath()
    var firstRun = true
    var collectData = false
    var totalTotalDistance : Double = 0
    var totalDistance : Double = 0.0
    
    var firstLoc = false
    
    var realTimeDistance = CLLocation()
    
    var locations = [CLLocation]()
    var elapsed: TimeInterval = 0
    var startTime = Date()
    var currentLoc = CLLocation()
    
    var currentTime = Date()
    var totalSeconds : Int = 0
    
    var globalVelocity : [Double] = []
    
    var startTimeDylan : Date? = nil

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let latestLocation: CLLocation = locations[locations.count - 1]
        var currentLatitude:Double = latestLocation.coordinate.latitude
        var currentLongitude:Double = latestLocation.coordinate.longitude
        
        if startLocation == nil {
            startLocation = latestLocation
        }
        
        //Geocoder:
        let geocoder = GMSGeocoder()
        var result = "result"
        var temp = CLLocationCoordinate2D(latitude: currentLatitude, longitude: currentLongitude)
        
        //GEOCODING*******
        geocoder.reverseGeocodeCoordinate(temp) {
            response , error in
            if let address = response?.firstResult() {
                if address.locality == nil || address.administrativeArea == nil {
                    result = "Unknown, USA"
                } else {
                    if address.administrativeArea! != "Washington" {
                        let city = "\(address.locality!), \(address.administrativeArea!)"
                        result = "Outside of WA"
                    } else {
                        result = "\(address.locality!), WA"
                    }
                    //print("CITY: \(result)")
                }
            }
            self.cityHeader.text = result
            self.locationIcon.isHidden = false
            self.transition(item: self.locationIcon)
            self.transition(item: self.cityHeader)
        }
        
        
        //TRACKING ********
        
        let location = latestLocation as! CLLocation   
        if tracking {
            print("Location is changing")
            let elapsedSeconds = Int(round(elapsed))

            //NSLog("testing if firstLoc is true \(firstLoc)")
//            if firstLoc {
//                realTimeDistance = CLLocation (latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//                currentLoc = CLLocation (latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//                startTime = location.timestamp
//                //NSLog("testing what start time is \(startTime)")
//                currentTime = location.timestamp
//                //NSLog("testing what current time is \(currentTime)")
//                //NSLog("testing what first location is \(realTimeDistance)")
//                firstLoc = false
//                //NSLog("testing if firstLoc is false \(firstLoc)")
//            } else {
//                
                currentLoc = CLLocation (latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                currentTime = location.timestamp
                print("\(location.coordinate.latitude), \(location.coordinate.longitude)")
                totalSeconds = realTimeSeconds(startDate: startTime, endDate: currentTime)
                //NSLog("testing what seconds difference is \(totalSeconds)")
                //NSLog("testing what original location is \(realTimeDistance)")
                //NSLog("testing what current location is \(currentLoc)")
                let meters = distanceCalc(coordinateOne: realTimeDistance, coordinateTwo: currentLoc)
                totalDistance += meters
                totalTotalDistance += meters
                
//            }

            add(location: location)
            
            realTimeDistance = currentLoc
            
            // Record each location for a new run
            
            
            
            //These are generally unnecesary for now. Add again when we want current velocy:
            
            var distanceStepTwo = totalTotalDistance * 1.09361  //1.09361 is yards conversion
             
            print("totalDistance: \(totalDistance))")
            print("meters: \(meters)")
            print("totalTotalDistance: \(totalTotalDistance)")
            elapsed = Date().timeIntervalSince(startTimeDylan!)
            print(elapsed)
            
            
            var velocity = Double(distanceStepTwo * 0.000568182) / Double(elapsed / 3600) //yards to miles; seconds to hours
            print("VELOCITY: \(velocity)")
            globalVelocity.append(velocity)
            self.currentMPH.text = "\(Int(round(velocity)))"
        }
        
    }

    func add(location: CLLocation) {
        self.locations.append(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Handle errors here 
    }
    
    
    
    
    
    func startTracking() {
        // Begins getting location data until stopped
        //self.locationManager.startUpdatingLocation()
        self.locations.removeAll(keepingCapacity: false)
        self.tracking = true
        self.firstLoc = true
        self.collectData = true
        self.trackStartTimeStamp = NSDate() as Date
        
        startTimeDylan = Date()
        print("here")
        
        totalTotalDistance = 0.0
    }
    
    func stopTracking() {
        self.tracking = false
        self.collectData = false
        totalTotalDistance = 0.0
        saveTracking()
    }
    

    
    func saveTracking() -> Void {
        
        let newTrip = Trip()
        newTrip.timestamp = Date()
        
        var index = 1
        var firstLocationLat : Double = 0.0
        var firstLocationLong : Double = 0.0
        var distanceInMeters : Double = 0.0
        
        for location in locations {
            NSLog("THIS IS THE CURRENT INDEX \(index)")
            if (index == 6){
                index = 1
                distanceInMeters = 0.0
            }
            if (index == 1){
                firstLocationLat = location.coordinate.latitude
                firstLocationLong = location.coordinate.longitude
                distanceInMeters = 0.0
            }
            
            let secondLocationLat = location.coordinate.latitude
            let secondLocationLong = location.coordinate.longitude
            
            let coordinateOne = CLLocation(latitude: firstLocationLat, longitude: firstLocationLong)
            let coordinateTwo = CLLocation(latitude: secondLocationLat, longitude: secondLocationLong)
            
            distanceInMeters += distanceCalc(coordinateOne: coordinateOne, coordinateTwo: coordinateTwo)
            
            firstLocationLat = secondLocationLat
            firstLocationLong = secondLocationLong
            
            let newLocation = Location()
            newLocation.latitude = Float(location.coordinate.latitude)
            newLocation.longitude = Float(location.coordinate.longitude)
            newLocation.timestamp = location.timestamp
            newLocation.save()
            newTrip.locations.append(newLocation)
            
            index += 1
        }
        newTrip.save()
        
        do{
            let realm = try Realm()
            let allTrips = realm.objects(Trip.self)
            print(allTrips)
            var startDates = [String]()
            var finalDistance = [String]()
            var totalTime = [String]()
            
            var index = 0
            for run in allTrips {
                let startTime = run.timestamp
                let calendar = Calendar.current
                
                
                let hour = calendar.component(.hour, from: startTime)
                let minutes = calendar.component(.minute, from: startTime)
                let seconds = calendar.component(.second, from: startTime)
                startDates.append("hours = \(hour):\(minutes):\(seconds)")
                
                
                var locationIndex = 1
                var timeOne = Date()
                
                for location in run.locations {
                    if (locationIndex == 1){
                        timeOne = location.timestamp
                    }
                    
                    let endIndex = run.locations.endIndex
                    print(endIndex)
                    
                    
                    if (locationIndex == endIndex){
                        let timeTwo = location.timestamp
                        
                        let runMinutes = minsBetweenDates(startDate: timeOne, endDate: timeTwo)
                        let runSeconds = secsBetweenDates(startDate: timeOne, endDate: timeTwo)
                        totalTime.append("\(runMinutes):\(runSeconds)")
                    }
                    
                    locationIndex+=1
                    
                }
                
                index+=1
            }
            
            for run in allTrips{
                var distanceInMeters : Double = 0.0
                var locationIndex = 1
                var coordinateOne = CLLocation()
                
                for location in run.locations {
                    if (locationIndex == 1){
                        coordinateOne = CLLocation(latitude: Double(location.latitude), longitude: Double(location.longitude))
                    }
                    
                    let coordinateTwo = CLLocation(latitude: Double(location.latitude), longitude: Double(location.longitude))
                    
                    distanceInMeters += distanceCalc(coordinateOne: coordinateOne, coordinateTwo: coordinateTwo)
                    
                    coordinateOne = CLLocation(latitude: Double(location.latitude), longitude: Double(location.longitude))
                    locationIndex += 1
                }
                
                finalDistance.append(String(distanceInMeters))
                distanceInMeters = 0.0
            }
            
            NSLog("total Time array \(totalTime)")
            NSLog("start dates array \(startDates)")
            NSLog("total distance array \(finalDistance)")
            
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }
    
    func distanceCalc(coordinateOne: CLLocation, coordinateTwo: CLLocation) -> Double {
        var distance : Double = 0.0
        distance = coordinateOne.distance(from: coordinateTwo)
        return distance
    }
    
    func minsBetweenDates(startDate: Date, endDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([Calendar.Component.minute], from: startDate, to: endDate)
        return components.minute!
    }
    
    func secsBetweenDates(startDate: Date, endDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([Calendar.Component.second], from: startDate, to: endDate)
        var seconds : Int = components.second!
        if (components.second! >= 60){
            seconds = seconds / 60
        }
        
        return seconds
    }
    
    func realTimeSeconds(startDate: Date, endDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([Calendar.Component.second], from: startDate, to: endDate)
        return components.second!
    }
}
