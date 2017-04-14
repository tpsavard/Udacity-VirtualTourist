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
    
    enum Results {
        case success
        case failure
    }
    
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
    
    // MARK:- Flickr REST API Methods
    
    class func getPhotos(completionHandler: @escaping (Results, [String : Any]?) -> ()) {
        // Build the request
        
//        A Model request:
//        https://api.flickr.com/services/rest/
//            ?
//            method=flickr.photos.search&
//            api_key=0104647d6e9b8b7d4b200da5bb2b8490&     (Hard-coded)
//            lat=47.6062&
//            lon=122.3321&
//            extras=url_z&                                 (Returns the URL for a 640x640 sized image)
//            format=json
        
        // Call Flickr
        
            // Catch any communication errors
        
            // Try to parse the information returned
        
    }
    
    class func getPhoto(url: String, latitude: Double, longitude: Double, index: Int, completionHandler: @escaping (Double, Double, Data, Int) -> ()) {
        
    }
    
}
