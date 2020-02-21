//
//  Event.swift
//  Science Week
//
//  Created by Mars Geldard on 18/6/19.
//  Copyright © 2019 Mars Geldard. All rights reserved.
//
//  This file is released under the terms of the MIT License.
//  Please see LICENSE.md in the root directory.

import UIKit

/// The state that a Venue is located in.
enum State: String, CaseIterable {
    case act, nsw, nt, qld, sa, tas, vic, wa
    
    var code: String { return self.rawValue.uppercased() }
    
    init? (code: String?) {
        guard let code = code else { return nil }
        self.init(rawValue: code.lowercased())
    }
}

/// The target audience for an event.
enum TargetAudience: String {
    case allAges = "All ages"
    case kids = "Kids"
    case adults = "Adults"
}

/// The venue that an event is taking place in.
struct Venue {
    var name: String? = nil
    var streetName: String? = nil
    var suburb: String? = nil
    var postcode: Int? = nil
    var latitude: Double? = nil
    var longitude: Double? = nil
    var hasDisabledAccess: Bool = false
    var isValid: Bool {
        return coords != nil || (streetName != nil && suburb != nil && postcode != nil)
    }
    
    var coords: (latitude: Double, longitude: Double)? {
        if let latitude = latitude, let longitude = longitude {
            return (latitude, longitude)
        }
        
        return nil
    }
    
    var description: String? {
        var string = ""
        
        if let name = name { string += "\(name)\n" }
        if let streetName = streetName { string += "\(streetName)\n" }
        if let suburb = suburb { string += "\(suburb) " }
        if let postcode = postcode { string += "\(postcode)" }
        
        return string.isEmpty ? nil : string
    }
    
    init() {}
}

/// The contact information for an Event.
struct Contact {
    var name: String? = nil
    var organisation: String? = nil
    var phone: String? = nil
    var email: String? = nil
    var isValid: Bool {
        return name != nil || organisation != nil || phone != nil || email != nil
    }
    
    init() {}
}

/// An event associated with National Science Week.
struct Event {
    var id: String = "EVENT-ID"
    var name: String = "Event Name"
    var type: String = "Other"
    var start: Date? = nil
    var end: Date? = nil
    var description: String? = nil
    var targetAudience: TargetAudience = .allAges
    var payment: String?
    var isFree: Bool = false
    var categories: [String] = []
    var bookingEmail: String? = nil
    var bookingUrl: String? = nil
    var bookingPhone: String? = nil
    var facebook: String? = nil
    var twitter: String? = nil
    var website: String? = nil
    var state: State? = nil
    var moreInfo: String? = nil
    var officialImageUrl: String? = nil
    var attractions: [String] = []
    
    var contact: Contact? = Contact()
    var venue: Venue? = Venue()
    var isFavourite: Bool = false
    
    var image: UIImage? {
        if let imageUrlString = officialImageUrl,
            let imageUrl = URL(string: imageUrlString),
            let data = try? Data(contentsOf: imageUrl),
            let image = UIImage(data: data) {
            return image
        }
        
        return nil
    }
    
    mutating func toggleFavourite() {
        isFavourite = !isFavourite
    }
    
    mutating func validate() {
        if let validContact = self.contact?.isValid,
            !validContact {
            contact = nil
        }
        
        if let validVenue = self.venue?.isValid,
            !validVenue {
            venue = nil
        }
    }
}
