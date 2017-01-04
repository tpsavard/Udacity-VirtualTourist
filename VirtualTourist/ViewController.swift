//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Savard, Tim on 1/3/17.
//  Copyright © 2017 Savard, Tim. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var placeholderView: UIView!

    var shown: Bool = false
    
    @IBAction func updateViews(_ sender: UIBarButtonItem) {
        let constraint = view.constraints.first {$0.identifier == "bottom"}
        if let constraint = constraint {
            constraint.constant = shown ? -128 : 0
            shown = !shown
            
            UIView.animate(withDuration: 0.35) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
}

