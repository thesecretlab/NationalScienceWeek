//
//  Events.swift
//  Science Week
//
//  Created by Mars Geldard on 10/6/19.
//  Copyright © 2019 Mars Geldard. All rights reserved.
//

import Foundation

/// Wrapper object that has a single attribute: an array of fetched Event objects.
public struct EventList: Decodable {
    var events: [Event]
}

/// Objects that holds details for a single Event on a single Date.
public struct Event: Decodable, Equatable {
    var id: String?
    var name: String?
    var start: Date?
    var end: Date?
    var description: String?
    var imageUrl: URL?
    var targetAudience: TargetAudience?
    var payment: String?
    var isFree: Bool?
    var additionalInfo: String?
    
    var contactName: String?
    var contactOrganisation: String?
    var contactPhone: String?
    var contactEmail: String?
    
    var bookingPhone: String?
    var bookingEmail: String?
    var bookingUrl: URL?
    
    var websiteUrl: URL?
    var facebookUrl: URL?
    var twitterUrl: URL?
    var state: State?
    var venue: Venue?
    
    public static func == (lhs: Event, rhs: Event) -> Bool {
        return (lhs.id == rhs.id) &&
            (lhs.name == rhs.name) &&
            (lhs.start == rhs.start) &&
            (lhs.description == rhs.description) &&
            (lhs.isFree == rhs.isFree) &&
            (lhs.state == rhs.state) &&
            (lhs.venue == rhs.venue)
    }
}

/// Object that holds Venue details for a single Event on a single Date.
public struct Venue: Decodable, Equatable {
    var name: String?
    var address: String?
    var suburb: String?
    var postcode: String?
    var latitude: Float?
    var longitude: Float?
    var hasDisabledAccess: Bool?
    
    var location: (lat: Float, long: Float)? {
        if let lat = self.latitude, let long = self.longitude {
            return (lat, long)
        }
        
        return nil
    }
    
    var isEmpty: Bool {
        return (self.name == nil) &&
            (self.address == nil) &&
            (self.suburb == nil) &&
            (self.postcode == nil) &&
            (self.location == nil)
    }
    
    public static func == (lhs: Venue, rhs: Venue) -> Bool {
        return (lhs.name == rhs.name) &&
            (lhs.address == rhs.address) &&
            (lhs.suburb == rhs.suburb) &&
            (lhs.postcode == rhs.postcode)
    }
}

/// Enumeration of valid values in EventTargetAudience field.
public enum TargetAudience: String, Decodable {
    case allAges = "All ages"
    case kids = "Kids"
    case adults = "Adults"
}

/// Enumeration of valid values in State field.
public enum State: String, Decodable {
    case act, nsw, vic, sa, nt, wa, tas, qld, nationwide
    
    init?(caseInsensitiveRawValue string: String?) {
        self.init(rawValue: string?.lowercased() ?? "")
    }
}
