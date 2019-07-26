//
//  MapViewController.swift
//  Science Week
//
//  Created by Mars Geldard on 17/6/19.
//  Copyright © 2019 Mars Geldard. All rights reserved.
//

import MapKit


class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // outlets that are attached to the view elements in the
    // Interface Builder Main.storyboard
    @IBOutlet var parentView: UIView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationButton: UIBarButtonItem!
    
    // called when top right button pressed
    @IBAction func locationButtonPressed(_ sender: Any) {
        locationManager.requestLocation()
    }
    
    private var locationManager = CLLocationManager()
    
    // called when the view's components have completed loading
    // but before they have necessarily appeared
    override func viewDidLoad() {
        super.viewDidLoad()
        setTheme()

        // we're the thing that wants to know about how the map view is doing
        mapView.delegate = self

        // we're the thing that wants to know how asking for location data is doing
        locationManager.delegate = self
        
        // we want to be able to see the user's location if possible
        mapView.showsUserLocation = true
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // load the map!
        updateLocationControls()
        annotateMap()
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
        locationButton.isEnabled = CLLocationManager.locationServicesEnabled()
    }
    
    // puts pins on map locations where known events are
    private func annotateMap() {
        for event in EventsList.events {
            let venue = event.venue
            
            if let coords = venue?.coords {
                let annotation = MKPointAnnotation()
                let centerCoordinate = CLLocationCoordinate2D(latitude: coords.latitude, longitude: coords.longitude)
                annotation.coordinate = centerCoordinate
                annotation.title = venue?.name ?? "Event Venue"
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    // sets app view colours to those declared in Theme settings
    private func setTheme() {
        navigationBar.titleTextAttributes = [.foregroundColor: Theme.primaryTextColour]
        navigationBar.tintColor = Theme.primaryAccentColour
        navigationBar.barStyle = Theme.lightTheme ? .default : .black
        parentView.backgroundColor = Theme.primaryBackgroundColour
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Theme.lightTheme ? UIStatusBarStyle.default : .lightContent
    }
}

// MARK: MKMapViewDelegate functions

extension MapViewController {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView {
        let view = MKMarkerAnnotationView()
        view.markerTintColor = Theme.mapAnnotationColour
        
        if let cluster = annotation as? MKClusterAnnotation {
            view.displayPriority = .defaultHigh
            view.glyphText = "\(cluster.memberAnnotations.count)"
            view.canShowCallout = false
        } else {
            view.displayPriority = .defaultLow
            view.clusteringIdentifier = "event"
            view.collisionMode = .circle
            view.canShowCallout = true
        }
        
        return view
    }
}

// MARK: CLLocationManagerDelegate functions

extension MapViewController {
    
    // called when a locate request yields a result
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coords = locations.last?.coordinate {
            let center = CLLocationCoordinate2D(latitude: coords.latitude, longitude: coords.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let region = MKCoordinateRegion(center: center, span: span)
            updateMapViewRegion(to: region)
        }
    }
    
    // called when a locate request fails to yield a result
    internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // ⚠️ do nothing because it will either try again or disable the button anyway
        // but we need this function here, else the app hard crashes (Thanks, Apple! 😂)
    }
    
    // called when the user either allows or disallows location tracking
    internal func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        updateLocationControls()
    }
}
