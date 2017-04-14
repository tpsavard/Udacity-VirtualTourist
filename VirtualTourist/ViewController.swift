//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Savard, Tim on 1/3/17.
//  Copyright © 2017 Savard, Tim. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var detailCollectionView: UICollectionView!
    
    var managedContext: NSManagedObjectContext?
    var selectedCoordinates: CLLocationCoordinate2D?

    // MARK:- View Controller Methods
    
    override func viewWillAppear(_ animated: Bool) {
        moveDetailView(show: false, animate: false)
        
        // Re-center the map view
        if let rawCoordinates: (Double, Double) = DataController.getMapView() {
            let coordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: rawCoordinates.0, longitude: rawCoordinates.1)
            mapView.setCenter(coordinates, animated: false)
        }
        
        // Get the Core Data context
        if let appDelegate: AppDelegate = UIApplication.shared.delegate as? AppDelegate {
            managedContext = appDelegate.persistentContainer.viewContext
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Save the map center point
        DataController.saveMapView(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
    }
    
    // MARK:- Map View Delegate Methods
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "pin"
        
        var annotationView: MKAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        if let annotationView = annotationView {
            annotationView.annotation = annotation
        } else {
            let newAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            newAnnotationView.canShowCallout = false
            annotationView = newAnnotationView
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("Map view annotation selected")
        
        selectedCoordinates = view.annotation?.coordinate
        detailCollectionView.reloadData()
        
        moveDetailView(show: true, animate: true)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        print("Map view annotation deselected")
        moveDetailView(show: false, animate: true)
    }
    
    // MARK:- Collection View Data Source Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sc = selectedCoordinates, let result = getLocationEntry(latitude: sc.latitude, longitude: sc.longitude) else {
            NSLog("Failed to get entity for location")
            return 0
        }
        
        // Return the count of photos for the location
        if let count = result.photos?.count {
            return count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Get a fresh cell
        let reuseIdentifier: String = "photocell"
        let cell: PhotoCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCell

        // Get the image to display
        let photo: UIImage? = nil
        
        // Decorate & return the cell
        cell.PhotoView.image = photo
        
        return cell
    }
    
    // MARK:- UI Methods
    
    @IBAction func selectMapLocation(_ sender: UILongPressGestureRecognizer) {
        print("longPressMapView IBAction called: \(sender.state.rawValue)")
        
        if sender.state == .ended {
            // Get the coordinates for the new pin
            let touchPoint: CGPoint = sender.location(in: mapView)
            let coordinate: CLLocationCoordinate2D = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            
            // Add the new pin, and mark it selected
            let annotation: MKPointAnnotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            mapView.selectAnnotation(annotation, animated: false)
            
            // Create the location entity
            addLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            // Update the detail view
            refreshDetailView()
            
            // Show the detail view
            moveDetailView(show: true, animate: true)
        }
    }
    
    @IBAction func close(_ sender: UIBarButtonItem) {
        print("close IBAction called")
        moveDetailView(show: false, animate: true)
    }
    
    @IBAction func refresh(_ sender: UIBarButtonItem) {
        print("refresh IBAction called")
        refreshDetailView()
    }
    
    @IBAction func remove(_ sender: UIBarButtonItem) {
        print("remove IBAction called")
        
        // Hide the detail view
        moveDetailView(show: false, animate: true)
        
        // Remove the currently selected pin (as implemented, there should only ever be one)
        mapView.removeAnnotations(mapView.selectedAnnotations)
    }
    
    // MARK:- Other Methods
    
    func moveDetailView(show: Bool, animate: Bool) {
        print("moveDetailView called")
        
        // Get the constraint values
        let uncheckedDistanceConstraint: NSLayoutConstraint? = view.constraints.first { $0.identifier == "bottom" }
        let uncheckedHeightConstraint: NSLayoutConstraint? = detailView.constraints.first { $0.identifier == "height" }
        guard let distanceConstraint = uncheckedDistanceConstraint, let heightConstraint = uncheckedHeightConstraint else {
            NSLog("Failed to get current constraint values")
            return
        }
        
        let distance: CGFloat = distanceConstraint.constant
        let height: CGFloat = heightConstraint.constant
        
        // Determine if Detail View needs to move, by determining if the detail view is not aligned to the bottom edge of the parent view
        let shown: Bool = distance == 0
        
        // Move detail view, if needed
        if shown != show {
            distanceConstraint.constant = shown ? -height : 0
            
            if animate {
                UIView.animate(withDuration: 0.35) { self.view.layoutIfNeeded() }
            } else {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func refreshDetailView() {
        print("refreshDetailView called")
        
        // Sanity check
        guard let managedContext = managedContext else {
            NSLog("Failed to get Managed Context")
            return
        }
        
        guard let sc = selectedCoordinates, let location = getLocationEntry(latitude: sc.latitude, longitude: sc.longitude) else {
            NSLog("Failed to get entity for location")
            return
        }
        
        // Clear out the old photos
        if let photos: [Photo] = location.photos?.array as? [Photo] {
            for photo in photos {
                managedContext.delete(photo)
            }
        }
        
        do {
            try managedContext.save()
        } catch {
            NSLog("Failed to clear previous photos for selected pin")
        }
        
        // Start the network indicator
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // Load the new photos
        DataController.getPhotos(completionHandler: processPhotos)
    }
    
    func processPhotos(result: DataController.Results, data: [String : Any]?) {
        
    }
    
    func prepopulateDetailView(count: Int) {
        print("prepopulateDetailView called")
        
        // Sanity check
        guard let managedContext = managedContext else {
            NSLog("Failed to get Managed Context")
            return
        }
        
        // Get the location 
        guard let sc = selectedCoordinates, let location = getLocationEntry(latitude: sc.latitude, longitude: sc.longitude) else {
            NSLog("Failed to get entity for location")
            return
        }
        
        // Create the placeholder cells
        for _ in 1...count  {
            let photo = NSEntityDescription.insertNewObject(forEntityName: "Photo", into: managedContext) as! Photo
            
            photo.location = location
            photo.image = nil
        }
        
        // Save the cells
        do {
            try managedContext.save()
        } catch {
            NSLog("Failed to save placeholder photo entities")
        }
        
        // Refresh the detail view
        detailCollectionView.reloadData()
    }
    
    func populateCell(latitude: Double, longitude: Double, content: Data, index: Int) {
        print("prepopulateDetailView called")
        
        // Sanity check
        guard let managedContext = managedContext else {
            NSLog("Failed to get Managed Context")
            return
        }
        
        // Get the location
        guard let sc = selectedCoordinates, let location = getLocationEntry(latitude: sc.latitude, longitude: sc.longitude) else {
            NSLog("Failed to get entity for location")
            return
        }
        
        // Find the next blank photo entity
        if let photos: [Photo] = location.photos?.array as? [Photo] {
            guard photos[index].image == nil else {
                NSLog("Failed to get blank photo entity")
                return
            }
            
            photos[index].image = NSData(data: content)
        }
        
        
        // Attach the photo, save
        do {
            try managedContext.save()
        } catch {
            NSLog("Failed to save photo")
        }
        
        // Update the corresponding detail view cell
        detailCollectionView.reloadData()
    }
    
    func finishRefresh() {
        print("finishRefresh called")
        
        // End the network indicator
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func getLocationEntry(latitude: Double, longitude: Double) -> Location? {
        print("getLocationEntry called")
        
        // Sanity check
        guard let managedContext = managedContext else {
            NSLog("Failed to get coordinates for selected pin")
            return nil
        }
        
        // Put together a predicated fetch for the location with the matching coordinates
        let coordinatePredicate: NSPredicate = NSPredicate(format: "latitude = %@ AND longitude = %@", latitude, longitude)
        let fetchRequest: NSFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Location")
        fetchRequest.predicate = coordinatePredicate
        
        // Run the fetch
        do {
            let results: [NSManagedObject] = try managedContext.fetch(fetchRequest)
            
            // There should only be one object for each coordinate
            return results.first as? Location
        } catch {
            print("Failed to CD fetch. (\(latitude), \(longitude))")
            return nil
        }
    }
    
    func addLocation(latitude: Double, longitude: Double) {
        print("addLocation called")
        
        // Sanity check
        guard let managedContext = managedContext else {
            NSLog("Failed to get coordinates for selected pin")
            return
        }
        
        // Insert the new entity, with no photos
        let location = NSEntityDescription.insertNewObject(forEntityName: "Location", into: managedContext) as! Location
        
        // Save the new values
        location.latitude = latitude
        location.longitude = longitude
        
        do {
            try managedContext.save()
        } catch {
            print("Failed to CD save.")
        }
        
    }
    
}

