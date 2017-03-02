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
        guard let managedContext = managedContext else {
            NSLog("Failed to get coordinates for selected pin")
            return 0
        }
        
        guard let selectedCoordinates = selectedCoordinates else {
            NSLog("Failed to get coordinates for selected pin")
            return 0
        }
        
        // Put together a predicated fetch for the location with the matching coordinates
        let coordinatePredicate: NSPredicate = NSPredicate(format: "latitude = %@ AND longitude = %@", selectedCoordinates.latitude, selectedCoordinates.longitude)
        let fetchRequest: NSFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Location")
        fetchRequest.predicate = coordinatePredicate
        
        // Run the fetch
        do {
            let results: [NSManagedObject] = try managedContext.fetch(fetchRequest)
            return results.count
        } catch let error as NSError {
            print("Failed to fetch. \(error), \(error.userInfo)")
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
            
            // TODO: Update the detail view
            
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
        // Clear out the old photos
        
        // Start the network indicator
        
        // Load the new photos
    }
    
    func prepopulateDetailView(count: Int) {
        // Refresh the count of photos
    }
    
    func populateCell(indexPath: NSIndexPath, content: UIImage) {
        // Referesh the contents of the photo cell
    }
    
    func finishRefresh() {
        // End the network indicator
    }
    
}

