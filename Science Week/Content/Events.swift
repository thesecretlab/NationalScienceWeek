//
//  Events.swift
//  Science Week
//
//  Created by Mars Geldard on 18/6/19.
//  Copyright © 2019 Mars Geldard. All rights reserved.
//

import Foundation

enum State: String {
    case act, nsw, nt, qld, sa, tas, vic, wa
    
    var code: String { return self.rawValue.uppercased() }
}

struct Venue {
    let name: String?
    let streetName: String?
    let suburb: String?
    let postcode: Int?
    let coords: (latitude: Double, longitude: Double)?
    let hasDisabledAccess: Bool
    
    init(name: String? = nil, streetName: String? = nil, suburb: String? = nil, postcode: Int? = nil, latitude: Double? = nil, longitude: Double? = nil, hasDisabledAccess: Bool? = false) {
        self.name = name
        self.streetName = streetName
        self.suburb = suburb
        self.postcode = postcode
        
        if let latitude = latitude, let longitude = longitude {
            self.coords = (latitude, longitude)
        } else {
            self.coords = nil
        }
        
        self.hasDisabledAccess = hasDisabledAccess ?? false
    }
}

struct Event {
    let id: String?
    let name: String?
    let type: String?
    let start: String?
    let end: String?
    let description: String?
    let targetAudience: String?
    let payment: String?
    let isFree: Bool
    let category: String?
    let contactName: String?
    let contactOrganisation: String?
    let contactPhone: String?
    let contactEmail: String?
    let bookingEmail: String?
    let bookingUrl: String?
    let bookingPhone: String?
    let facebook: String?
    let twitter: String?
    let website: String?
    let state: String?
    let moreInfo: String?
    let officialImageUrl: String?
    let attractions: String?
    let venue: Venue
    
    private(set) var isFavourite: Bool = false
    
    mutating func toggleFavourite() {
        isFavourite = !isFavourite
    }
}

class EventsList {
    private static var shared = EventsList()
    static var events: [Event] {
        let venue = Venue(name: "Hadley's Orient Hotel", streetName: "34 Murray Street", suburb: "Hobart", postcode: 7000, latitude: -42.8838192, longitude: 147.3279715, hasDisabledAccess: false)
        let event = Event(id: "SW69117", name: "Painting a changing world: how art and science can speak together in a time of environmental change. A special Hadley’s Art Prize event", type: "Other", start: "2019-08-11T14:00:00", end: "2019-08-11T15:00:00", description: "Why do palaeoecologists look at art? What is the role of art in conservation? And how might art and science come together to help us respond to environmental change? Come and hear scientists, artists and curators reflect at a special Hadley's Art Prize afternoon tea (tea, coffee &amp;amp; scones provided). ", targetAudience: "All ages", payment: "", isFree: true, category: "Science &amp; Technology ~ Archaeology and Antiquity", contactName: "Penny Jones", contactOrganisation: "Menzies Institute for Medical Research, University of Tasmania", contactPhone: "0490 389 415", contactEmail: "Penelope.Jones@utas.edu.au", bookingEmail: "", bookingUrl: "https://www.eventbrite.com.au/e/painting-a-changing-world-tickets-62895498128?aff=ebdssbdestsearch", bookingPhone: "", facebook: "https://www.facebook.com/pg/hadleysartprize/posts/", twitter: "", website: "https://www.hadleysartprize.com.au/", state: "TAS", moreInfo: "", officialImageUrl: "https://www.scienceweek.net.au/wp-content/uploads/2019/06/megan-walch-land-of-fire-and-flood2.jpg", attractions: nil, venue: venue)
        return [event]
    }
    
    private init() {}
    
    
}
