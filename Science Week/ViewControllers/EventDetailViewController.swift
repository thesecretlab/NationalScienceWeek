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

import SafariServices

import SDWebImage

class EventDetailViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var eventInfoStackView: UIStackView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var eventImageViewAspectRatio: NSLayoutConstraint!
    
    // Booking and social links
    @IBOutlet weak var bookOnlineButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var linkButton: UIButton!
    
    @IBOutlet weak var contactInfoView: UIStackView!
    
    @IBOutlet weak var contactInfoStackView: UIStackView!
    
    static var eventDateFormatter : DateFormatter = {
        let d = DateFormatter()
        
        d.dateFormat = "EEEE, MMMM dd"
        
        return d
    }()
    
    static var timeFormatter : DateFormatter = {
        let d = DateFormatter()
        
        d.dateFormat = "h:mm a"
        
        return d
    }()
    
    func addInfoLabel(title: String, text: String, labelWidth : CGFloat = 80, stackView : UIStackView? = nil, onClick: (() -> Void)? = nil) {
        
        let titleLabel = UILabel(frame: CGRect.zero)
        
        titleLabel.text = title + ":"
        titleLabel.font = UIFont.preferredFont(forTextStyle: .body).bold()
        titleLabel.textColor = .white
        titleLabel.textAlignment = .right
        titleLabel.numberOfLines = 0
        
        titleLabel.widthAnchor.constraint(equalToConstant: labelWidth).isActive = true
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        let textLabel = UILabel(frame: CGRect.zero)
        
        textLabel.text = text
        textLabel.font = UIFont.preferredFont(forTextStyle: .body)
        textLabel.textColor = .white
        textLabel.numberOfLines = 0
        
        if let onClick = onClick {
            textLabel.textColor = Theme.primaryAccentColour
            textLabel.addGestureRecognizer(UITapGestureRecognizerWithClosure(closure: onClick))
            textLabel.isUserInteractionEnabled = true
        }
        
        textLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        let newStackView = UIStackView(arrangedSubviews: [titleLabel, textLabel])
        newStackView.alignment = .top
        newStackView.axis = .horizontal
        
        newStackView.spacing = UIStackView.spacingUseSystem
        
        
        (stackView ?? eventInfoStackView).addArrangedSubview(newStackView)
        
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
        
        addInfoLabel(title: "Is Free", text: event.isFree ? "Yes" : "No")
        
        if let payment = event.payment {
            addInfoLabel(title: "Payment", text: payment)
        }
        
        addInfoLabel(title: "For", text: event.targetAudience.rawValue)
        
        contactInfoView.isHidden = event.contact == nil
        
        if let contact = event.contact {
            let labelWidth : CGFloat = 120
            contactInfoStackView.removeAllArrangedSubviews()
            
            if let name = contact.name { addInfoLabel(title: "Name", text: name, labelWidth: labelWidth, stackView: contactInfoStackView) }
            if let org = contact.organisation { addInfoLabel(title: "Organisation", text: org, labelWidth: labelWidth, stackView: contactInfoStackView) }
            if let phone = contact.phone {
                addInfoLabel(title: "Phone", text: phone, labelWidth: labelWidth, stackView: contactInfoStackView) {
                    guard let url = URL(string: "tel:"+phone) else { return }
                    UIApplication.shared.open(url)
                }
            }
            if let email = contact.email {
                addInfoLabel(title: "Email", text: email, labelWidth: labelWidth, stackView: contactInfoStackView) {
                    guard let url = URL(string: "mailto:"+email) else { return }
                    UIApplication.shared.open(url)
                }
            }
        }
        
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
        
        twitterButton.isHidden = event.twitter == nil
        facebookButton.isHidden = event.facebook == nil
        linkButton.isHidden = event.website == nil
        bookOnlineButton.isHidden = event.bookingUrl == nil
        phoneButton.isHidden = event.bookingPhone == nil
        emailButton.isHidden = event.bookingEmail == nil
        
        if let imageURLString = event.officialImageUrl, let imageURL = URL(string:imageURLString) {
            eventImageView.image = nil
            eventImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            eventImageView.backgroundColor = .darkGray
            eventImageView!.sd_setImage(with: imageURL) { (image, error, cacheType, url) in
                if let image = image {
                    self.headerImageView.image = image

//                    let aspectRatio = image.size.width / image.size.height
//                    self.eventImageViewAspectRatio.isActive = false
//
//                    self.eventImageViewAspectRatio = self.eventImageView.widthAnchor.constraint(equalTo: self.eventImageView.heightAnchor, multiplier: aspectRatio)
//                    self.eventImageViewAspectRatio.isActive = true
//                    self.view.layoutIfNeeded()
                    
                    self.eventImageView.backgroundColor = .clear
                } else {
                    self.eventImageView.isHidden = true
                }
            }
            eventImageView.isHidden = false
        } else {
            eventImageView.isHidden = true
        }
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
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

    @IBAction func bookOnlineTapped(_ sender: Any) {
        if let url = URL(string: event?.bookingUrl ?? "") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func bookByEmailTapped(_ sender: Any) {
        guard let email = event?.bookingEmail else { return }
        
        if let url = URL(string: "mailto:" + email) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func bookByPhone(_ sender: Any) {
        guard let phone = event?.bookingPhone else { return }
        
        if let url = URL(string: "tel:" + phone) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func showTwitterTapped(_ sender: Any) {
        
        // Ensure we have a URL or username or _something_
        guard let twitter = event?.twitter else { return }
        
        // Guess at whether this is a URL or a username. Usefully,
        // http://twitter.com/@username and http://twitter.com/username
        // go to the same thing, so if we don't think this is a URL, just stick what we have
        // to the end of twitter.com and hope that'll work
        let urlString = twitter.starts(with: "http") ? twitter : "https://twitter.com/" + twitter
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func showFacebookTapped(_ sender: Any) {
        if let url = URL(string: event?.facebook ?? "") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func showMoreInfoLink(_ sender: Any) {
        if let url = URL(string: event?.website ?? "") {
            UIApplication.shared.open(url)
        }
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

class UITapGestureRecognizerWithClosure: UITapGestureRecognizer {
    private var invokeTarget:UIGestureRecognizerInvokeTarget
    
    init(closure:@escaping () -> ()) {
        // we need to make a separate class instance to pass
        // to super.init because self is not available yet
        self.invokeTarget = UIGestureRecognizerInvokeTarget(closure: closure)
        super.init(target: invokeTarget, action: #selector(invokeTarget.invoke(fromTarget:)))
    }
}

// this class defines an object with a known selector
// that we can use to wrap our closure
class UIGestureRecognizerInvokeTarget: NSObject {
    private var closure:() -> ()
    
    init(closure:@escaping () -> ()) {
        self.closure = closure
        super.init()
    }
    
    @objc public func invoke(fromTarget gestureRecognizer: UIGestureRecognizer) {
        self.closure()
    }
}
