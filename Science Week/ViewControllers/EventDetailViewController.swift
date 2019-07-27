//
//  EventDetailViewController.swift
//  Science Week
//
//  Created by Jonathon Manning on 27/7/19.
//  Copyright © 2019 Mars Geldard. All rights reserved.
//

import UIKit
import MapKit
import Contacts

class EventDetailViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var eventInfoStackView: UIStackView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var moreInfoLabel: UILabel!
    
    // Booking and social links
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var linkButton: UIButton!
    
    static var eventDateFormatter : DateFormatter = {
        let d = DateFormatter()
        
        d.dateFormat = "EEEE, MMMM dd"
        
        return d
    }()
    
    static var timeFormatter : DateFormatter = {
        let d = DateFormatter()
        
        d.dateFormat = "hh:mm a"
        
        return d
    }()
    
    func addInfoLabel(title: String, text: String) {
        
        let titleLabel = UILabel(frame: CGRect.zero)
        
        titleLabel.text = title + ":"
        titleLabel.font = UIFont.preferredFont(forTextStyle: .body).bold()
        titleLabel.textColor = .white
        titleLabel.textAlignment = .right
        titleLabel.numberOfLines = 0
        
        titleLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        let textLabel = UILabel(frame: CGRect.zero)
        
        textLabel.text = text
        textLabel.font = UIFont.preferredFont(forTextStyle: .body)
        textLabel.textColor = .white
        textLabel.numberOfLines = 0
        
        textLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, textLabel])
        stackView.alignment = .top
        stackView.axis = .horizontal
        
        stackView.spacing = UIStackView.spacingUseSystem
        
        eventInfoStackView.addArrangedSubview(stackView)
        
    }
    
    public var event : Event? {
        didSet {
            if isViewLoaded {
                updateContent()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateContent()

        // Do any additional setup after loading the view.
    }
    
    func updateContent() {
        
        eventInfoStackView.removeAllArrangedSubviews()
        
        guard let event = self.event else {
            return
        }
        
        titleLabel.text = event.name
        
        var descriptionText = event.description ?? ""
        
        if let moreInfo = event.moreInfo {
            descriptionText += "\n" + moreInfo
        }
        
        descriptionLabel.text = descriptionText
        
        if let start = event.start, let end = event.end {
            let startDate = EventDetailViewController.eventDateFormatter.string(from: start)
            let startTime = EventDetailViewController.timeFormatter.string(from: start)
            let endTime = EventDetailViewController.timeFormatter.string(from: end)
            
            let times = "\(startDate), \(startTime) - \(endTime)"
            
            addInfoLabel(title: "When", text: times)
        }
        
        
        if let venue = event.venue, let description = venue.description {
            addInfoLabel(title: "Where", text: description)
        }
        
        addInfoLabel(title: "For", text: event.targetAudience.rawValue)
        
        mapView.removeAnnotations(mapView.annotations)
        
        if let venue = event.venue, let coords = venue.coords {
            mapView.isHidden = false
            let annotation = MKPointAnnotation()
            let centerCoordinate = CLLocationCoordinate2D(latitude: coords.latitude, longitude: coords.longitude)
            annotation.coordinate = centerCoordinate
            annotation.title = venue.name ?? "Event Venue"
            mapView.addAnnotation(annotation)
            
            // Show a region 5 kilometers around the point
            let region = MKCoordinateRegion(center: centerCoordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
            
            mapView.setRegion(region, animated: false)
        } else {
            mapView.isHidden = true
        }
    }
    
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
    
    
    @IBAction func mapViewTapped(_ map: Any) {
        guard let location = event?.venue, let coords = event?.venue?.coords else { return }
        
        let coordinates = CLLocationCoordinate2D(latitude: coords.latitude, longitude: coords.longitude)
        
        let addressDictionary : [String:Any?] = [
            CNPostalAddressStreetKey: location.streetName,
            CNPostalAddressCityKey: location.suburb,
            CNPostalAddressPostalCodeKey: location.postcode?.description]
        
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: addressDictionary as [String : Any])
        
        let item = MKMapItem(placemark: placemark)
        
        item.name = event?.name
        
        item.openInMaps(launchOptions: [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: coordinates)
            ])
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIStackView {
    
    func removeAllArrangedSubviews() {
        
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        
        // Deactivate all constraints
        NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))
        
        // Remove the views from self
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
}

extension UIFont {
    
    func withTraits(traits:UIFontDescriptor.SymbolicTraits...) -> UIFont {
        guard let descriptor = self.fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits)) else {
            print("Failed to find appropriate font based on \(self.description) with traits \(traits); falling back to unmodified font")
            return self
        }
        return UIFont(descriptor: descriptor, size: 0)
    }
    
    func bold() -> UIFont {
        return withTraits(traits: .traitBold)
    }
    
    func italic() -> UIFont {
        return withTraits(traits: .traitItalic)
    }
    
    func boldItalic() -> UIFont {
        return withTraits(traits: .traitBold, .traitItalic)
    }
    
}
