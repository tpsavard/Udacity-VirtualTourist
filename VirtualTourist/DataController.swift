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
    
    class func getPhotos(latitude: Double, longitude: Double, completionHandler: @escaping (Results, [String : Any]?) -> ()) {
        // Build the request
        
//        A Model request:
//        https://api.flickr.com/services/rest/
//            ?
//            method=flickr.photos.search&
//            api_key=0104647d6e9b8b7d4b200da5bb2b8490&     (user-specific)
//            lat=47.6062&
//            lon=122.3321&
//            extras=url_z&                                 (Returns the URL for a 640x640 sized image)
//            format=json
        
        var url = "https://api.flickr.com/services/rest/?"
        url.append("method=flickr.photos.search&")
        url.append("api_key=0104647d6e9b8b7d4b200da5bb2b8490&")
        url.append("lat=\(latitude)&")
        url.append("lon=\(latitude)&")
        url.append("extras=url_z&")
        url.append("format=json&")
        url.append("nojsoncallback=true")
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        
        // Call Flickr
        NSLog("Searching for photos at given location")
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            // Verify a good response
            if let error = error {
                NSLog("Log in failed for networking error: \(error)")
                DispatchQueue.main.async() {
                    completionHandler(Results.failure, nil)
                }
            }
            
            // Try to parse whatever we received; if we fail, assume that the data was currupted as received
            guard let parsedData: [String : Any] = self.fromJSONToDict(data: data) as? [String : Any] else {
                NSLog("Error serializing log in response")
                DispatchQueue.main.async() {
                    completionHandler(Results.failure, nil)
                }
                return
            }
            
            NSLog("Search successful")
            DispatchQueue.main.async() {
                completionHandler(Results.success, parsedData)
            }
        }
        task.resume()
    }
    
    class func getPhoto(url: String, latitude: Double, longitude: Double, index: Int, completionHandler: @escaping (Double, Double, Data, Int) -> ()) {
        // TODO: ...
    }
    
    // MARK:- Other Methods
    
    class func fromJSONToDict(data: Data?) -> Any? {
        guard let data = data else {
            return nil
        }
        
        do {
            let dict = try JSONSerialization.jsonObject(with: data)
            return dict
        } catch {
            return nil
        }
    }
    
}
