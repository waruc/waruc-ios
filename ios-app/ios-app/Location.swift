//
//  Location.swift
//  ios-app
//
//  Created by Babbs, Dylan on 6/3/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import Foundation
import GoogleMaps
import CoreLocation

class Location: NSObject, CLLocationManagerDelegate {
    
    override init() {
        super.init()
    }
    
    static let sharedInstance = Location()
    
    var washington = true
    
    var locationManager = CLLocationManager()
    
    //Tracking setup
    var tracking = false
    var realTimeDistance = CLLocation()
    var currentLoc = CLLocation()
    var tripDistance = Double()
    var tripStartTime = Date()
    var initialLocation = false
    
    func startTracking() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 25 //meter interval for location updating
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        initialLocation = true
        self.tracking = true
        self.tripStartTime = Date()
        print("*** 📍GPS: Successfully connected!💦 ***")
    }
    
    func stopTracking() {
        self.tracking = false
        // Convert meters to miles w/ tripDistance * 0.000621371
        if washington {
            DB.sharedInstance.writeTrip(miles: tripDistance * 0.000621371, vin: "location")
        }
        tripDistance = 0.0
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // App may no longer be authorized to obtain location
        //information. Check status here and respond accordingly
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Handle errors here 
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations[locations.count - 1]
        let currentLatitude:Double = location.coordinate.latitude
        let currentLongitude:Double = location.coordinate.longitude
        
        // Reverse geocoder to update city label
        let geocoder = GMSGeocoder()
        var result = "result"
        let temp = CLLocationCoordinate2D(latitude: currentLatitude, longitude: currentLongitude)
        
        geocoder.reverseGeocodeCoordinate(temp) {
            response , error in
            if let address = response?.firstResult() {
                if address.locality == nil || address.administrativeArea == nil {
                    result = "Unknown, USA"
                } else {
                    if address.administrativeArea! != "Washington" {
                        _ = "\(address.locality!), \(address.administrativeArea!)"
                        result = "Outside of WA"
                        self.washington = false
                    } else {
                        result = "\(address.locality!)"
                    }
                    print("CITY: \(result)")
                    if result.characters.count < 13 {
                        result += ", WA"
                    } else if result.characters.count > 15 {
                        let index = result.index(result.startIndex, offsetBy: 13)
                        result = result.substring(to: index)
                        result += "..."
                    }
                    //result = "123456789012" //15
                }
            }
            let resultDict:[String: String] = ["text": result]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "cityHeaderNotification"), object: nil, userInfo: resultDict)
            let hideDict:[String: Bool] = ["status": false]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "locationIconNotification"), object: nil, userInfo: hideDict) 
        }
        
        //GPS tracking 
        if tracking {  
            if initialLocation {
                realTimeDistance = CLLocation (latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                currentLoc = CLLocation (latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                initialLocation = false
            } else {
                currentLoc = CLLocation (latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                //print("\(location.coordinate.latitude), \(location.coordinate.longitude)")
                let meters = distanceCalc(coordinateOne: realTimeDistance, coordinateTwo: currentLoc)
                tripDistance += meters
            }
            realTimeDistance = currentLoc
        }
    }
    
    func distanceCalc(coordinateOne: CLLocation, coordinateTwo: CLLocation) -> Double {
        /* 
        From Apple:
        This method measures the distance between the two locations by tracing a line 
        between them that follows the curvature of the Earth. The resulting arc is a 
        smooth curve and does not take into account specific altitude changes between 
        the two locations.
        */
         
        var distance : Double = 0.0
        distance = coordinateOne.distance(from: coordinateTwo)
        return distance
    }
}
