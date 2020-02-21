//
//  MapViewController.swift
//  Science Week
//
//  Created by Mars Geldard on 17/6/19.
//  Copyright © 2019 Mars Geldard. All rights reserved.
//
//  This file is released under the terms of the MIT License.
//  Please see LICENSE.md in the root directory.

import MapKit


class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    class EventAnnotation : NSObject, MKAnnotation {
        var coordinate: CLLocationCoordinate2D
        
        var title: String?
        
        var event : Event
        
        init?(event: Event) {
            
            guard let position = event.venue?.coords else {
                return nil
            }
            
            self.event = event
            self.title = event.name
            self.coordinate = CLLocationCoordinate2D(
                latitude: CLLocationDegrees(position.latitude),
                longitude: CLLocationDegrees(position.longitude)
            )
        }
    }
    
    // outlets that are attached to the view elements in the
    // Interface Builder Main.storyboard
    @IBOutlet var parentView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationButton: UIBarButtonItem!
    
    let locationManager = CLLocationManager()
    
    // called when top right button pressed
    @IBAction func locationButtonPressed(_ sender: Any) {
        let location = self.mapView.userLocation
        
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
        
        self.mapView.setRegion(region, animated: true)
    }
    
    // called when the view's components have completed loading
    // but before they have necessarily appeared
    override func viewDidLoad() {
        super.viewDidLoad()
        setTheme()
        
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        
        

        // we're the thing that wants to know about how the map view is doing
        mapView.delegate = self

        // we want to be able to see the user's location if possible
        mapView.showsUserLocation = true
        
        // load the map!
        updateLocationControls()
        annotateMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        for annotation in mapView.selectedAnnotations {
            mapView.deselectAnnotation(annotation, animated: false)
        }
    }
    
    func refresh() {
        let userLocation = mapView.userLocation
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(userLocation)
        
        annotateMap()
    }
    
    // move and zoom the mapView to the place we want
    private func updateMapViewRegion(to region: MKCoordinateRegion) {
        mapView.setRegion(region, animated: true)
    }
    
    // disable the location button if user location is not permitted or available
    private func updateLocationControls() {
        locationButton.isEnabled = CLLocationManager.authorizationStatus() == .authorizedWhenInUse
    }
    
    // puts pins on map locations where known events are
    private func annotateMap() {
        for event in EventsList.events {
            if let annotation = EventAnnotation(event: event) {
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    // sets app view colours to those declared in Theme settings
    private func setTheme() {
        
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: Theme.primaryTextColour]
        self.navigationController?.navigationBar.tintColor = Theme.primaryAccentColour        
        self.navigationController?.navigationBar.barStyle = Theme.lightTheme ? .default : .black
        parentView?.backgroundColor = Theme.primaryBackgroundColour
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Theme.lightTheme ? UIStatusBarStyle.default : .lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let event = sender as? Event,
            let eventController = segue.destination as? EventDetailViewController
        {
            // Deliver the event to the view controller
            eventController.event = event
        }
        
        if let cluster = sender as? MKClusterAnnotation,
            let eventListController = segue.destination as? EventsViewController {
            
            eventListController.listType = .specifiedEvents
            
            let events = cluster.memberAnnotations.compactMap({ ($0 as? EventAnnotation)?.event})
            
            eventListController.events = events
            
        }
    }
}

// MARK: MKMapViewDelegate functions

extension MapViewController {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let view = MKMarkerAnnotationView()
        view.markerTintColor = Theme.mapAnnotationColour
        
        if let cluster = annotation as? MKClusterAnnotation {
            view.displayPriority = .defaultHigh
            view.glyphText = "\(cluster.memberAnnotations.count)"
            view.canShowCallout = false
        } else if let annotation = annotation as? EventAnnotation {
            view.displayPriority = .defaultLow
            view.clusteringIdentifier = "event"
            view.collisionMode = .circle
            view.canShowCallout = true
        } else {
            return nil
        }
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let clusterAnnotation = view.annotation as? MKClusterAnnotation {
            //NSLog("Selected cluster annotation: \(clusterAnnotation.memberAnnotations.count)")
            self.performSegue(withIdentifier: "showEventList", sender: clusterAnnotation)
        }
        
        if let eventAnnotation = view.annotation as? EventAnnotation {
            self.performSegue(withIdentifier: "showEvent", sender: eventAnnotation.event)
        }
    }
}

// MARK: CLLocationManagerDelegate functions

extension MapViewController {
    
    
    // called when the user either allows or disallows location tracking
    internal func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        updateLocationControls()
    }
}
