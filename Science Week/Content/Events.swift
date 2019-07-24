//
//  Events.swift
//  Science Week
//
//  Created by Mars Geldard on 18/6/19.
//  Copyright © 2019 Mars Geldard. All rights reserved.
//

import Foundation

enum State: String, CaseIterable {
    case act, nsw, nt, qld, sa, tas, vic, wa
    
    var code: String { return self.rawValue.uppercased() }
}

enum TargetAudience: String {
    case allAges = "All ages"
    case kids = "Kids"
    case adults = "Adults"
}

struct Venue {
    var name: String = "Venue Name"
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
    
    init() {}
}

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
struct Event {
    var id: String? = nil
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

//    private var exampleEvents: [Event] {
//        let venue = Venue(name: "Hadley's Orient Hotel", streetName: "34 Murray Street", suburb: "Hobart", postcode: 7000, latitude: -42.8838192, longitude: 147.3279715, hasDisabledAccess: false)
//        let event = Event(id: "SW69117", name: "Painting a changing world: how art and science can speak together in a time of environmental change. A special Hadley’s Art Prize event", type: "Other", start: "2019-08-11T14:00:00", end: "2019-08-11T15:00:00", description: "Why do palaeoecologists look at art? What is the role of art in conservation? And how might art and science come together to help us respond to environmental change? Come and hear scientists, artists and curators reflect at a special Hadley's Art Prize afternoon tea (tea, coffee &amp;amp; scones provided). ", targetAudience: "All ages", payment: "", isFree: true, category: "Science &amp; Technology ~ Archaeology and Antiquity", contactName: "Penny Jones", contactOrganisation: "Menzies Institute for Medical Research, University of Tasmania", contactPhone: "0490 389 415", contactEmail: "Penelope.Jones@utas.edu.au", bookingEmail: "", bookingUrl: "https://www.eventbrite.com.au/e/painting-a-changing-world-tickets-62895498128?aff=ebdssbdestsearch", bookingPhone: "", facebook: "https://www.facebook.com/pg/hadleysartprize/posts/", twitter: "", website: "https://www.hadleysartprize.com.au/", state: "TAS", moreInfo: "", officialImageUrl: "https://www.scienceweek.net.au/wp-content/uploads/2019/06/megan-walch-land-of-fire-and-flood2.jpg", attractions: nil, venue: venue, isFavourite: false)
//        return [event]
//    }
