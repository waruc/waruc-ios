//
//  master.swift
//  ios-app
//
//  Created by Babbs, Dylan on 5/4/17.
//  Copyright © 2017 Nicholas Nordale. All rights reserved.
//

import Foundation
import UIKit


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
                    //trips.sayHi()
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

struct Colors {
    static let purple = UIColor(red:0.58, green:0.11, blue:1.00, alpha:1.0)
    static let black = UIColor(red:0.00, green:0.00, blue:0.00, alpha:1.0)
    static let green = UIColor(red:0.22, green:0.78, blue:0.51, alpha:1.0)
    static let backgroundBlack = UIColor(red:0.13, green:0.13, blue:0.15, alpha:1.0)
    static let white = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
    static let lightGrey = UIColor(red:0.93, green:0.93, blue:0.93, alpha:1.0)
    static let darkGrey = UIColor(red:0.61, green:0.61, blue:0.61, alpha:1.0)
    
}
