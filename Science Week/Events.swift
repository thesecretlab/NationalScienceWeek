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
public struct Event: Decodable {
    var id: String?
    var name: String?
    var start: Date?
    var end: Date?
    var description: String?
    var targetAudience: TargetAudience?
    var payment: String?
    var isFree: Bool?
    var categories: [String]
    var state: State?
    var additionalInformation: String?
    var imageUrl: URL?
    var contactDetails: ContactDetails?
    var bookingDetails: BookingDetails?
    var socialDetails: SocialDetails?
    var venueDetails: VenueDetails?
}

/// Object that holds ContactDetails for a single Event on a single Date.
public struct ContactDetails: Decodable {
    var name: String?
    var organisation: String?
    var telephone: String?
    var email: String?
}

/// Object that holds BookingDetails for a single Event on a single Date.
public struct BookingDetails: Decodable {
    var email: String?
    var url: URL?
    var phone: String?
}

/// Object that holds SocialDetails for a single Event on a single Date.
public struct SocialDetails: Decodable {
    var website: URL?
    var facebook: URL?
    var twitter: URL?
}

/// Object that holds VenueDetails for a single Event on a single Date.
public struct VenueDetails: Decodable {
    var name: String?
    var address: String?
    var suburb: String?
    var postcode: String?
    var location: (lat: Float, long: Float)?
    var hasDisabledAccess: Bool
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
