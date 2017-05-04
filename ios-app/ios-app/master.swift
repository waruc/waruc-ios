//
//  master.swift
//  ios-app
//
//  Created by Babbs, Dylan on 5/4/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import Foundation

struct States {
    
    struct Activity {
        
        //start/stop drive button
        static var track = false {
        
            willSet(track) {
                print("this is test.")
            }
            
            //if track value is changed
            didSet {
                if track  {
                    print("MASTER:: track is \(track)")
                    
                    //attempt to call method from TripsViewController
                    let trips = TripsViewController()
                    trips.sayHi()
                    //^ sayHi() methods works fine because all it does is print hello. Issue comes when
                    // I try to call setBlack(), gives optional error of some sort. I think it has to do
                    //with access view.backgroundColor, specifically the "view" part. Not sure why.
                    
                } else {
                    print("MASTER:: track is \(track)")

                }
            }
        }
    }
}
