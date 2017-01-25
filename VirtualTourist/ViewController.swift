//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Savard, Tim on 1/3/17.
//  Copyright © 2017 Savard, Tim. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var detailView: UIView!

    // MARK:- View Controller Methods
    
    override func viewWillAppear(_ animated: Bool) {
        moveDetailView(show: false, animate: false)
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
        moveDetailView(show: true, animate: true)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        print("Map view annotation deselected")
        moveDetailView(show: false, animate: true)
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
    
}

