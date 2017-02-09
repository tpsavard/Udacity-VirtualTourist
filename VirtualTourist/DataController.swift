//
//  DataController.swift
//  VirtualTourist
//
//  Created by Savard, Tim on 2/8/17.
//  Copyright © 2017 Savard, Tim. All rights reserved.
//

import Foundation
import MapKit

class DataController {
    
    static let plistName: String = "VirtualTourist"
    static let latitudeLabel: String = "latitude"
    static let logitudeLabel: String = "logitude"
    
    // MARK:- plist Methods
    
    class func saveMapView(latitude: Double, longitude: Double) {
        NSLog("saveMapView called")
        
        // Contruct the plist contents
        let data = NSDictionary(dictionary: [
            latitudeLabel : latitude,
            logitudeLabel : longitude
        ])
        
        // Write the plist
        guard let path: String = Bundle.main.path(forResource: plistName, ofType: "plist") else {
            NSLog("Failed to find plist file")
            return
        }
        
        if !data.write(toFile: path, atomically: true) {
            NSLog("Fail to write plist file")
        }
    }
    
    class func getMapView() -> (latitude: Double, longitude: Double)? {
        NSLog("getMapView called")
        
        // Get the plist
        guard let path: String = Bundle.main.path(forResource: plistName, ofType: "plist") else {
            NSLog("Failed to find plist file")
            return nil
        }
        
        guard let data: NSDictionary = NSDictionary(contentsOfFile: path) else {
            NSLog("Failed to load plist file")
            return nil
        }
        
        // Fetch the relevant values
        guard let latitude: Double = data[latitudeLabel] as? Double, let logitude: Double = data[logitudeLabel] as? Double else {
            NSLog("Failed to get plist values")
            return nil
        }
        
        return (latitude, logitude)
    }
    
}
