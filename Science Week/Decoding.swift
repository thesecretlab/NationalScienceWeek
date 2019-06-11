//
//  Decoding.swift
//  Science Week
//
//  Created by Mars Geldard on 11/6/19.
//  Copyright © 2019 Mars Geldard. All rights reserved.
//

import Foundation

extension KeyedDecodingContainer {
    public func decodeIfPresent<T: Decodable>(key: KeyedDecodingContainer.Key) -> T? {
        let value = try? decodeIfPresent(T.self, forKey: key)
        return value
    }
    
    public func decodeIfPresentIgnoringEmpty<T: Decodable>(key: KeyedDecodingContainer.Key) -> T? where T: Collection {
        let value = try? decodeIfPresent(T.self, forKey: key)
        return (value?.isEmpty ?? true) ? nil : value
    }
    
    public func decodeIfPresentIgnoringEmpty(key: KeyedDecodingContainer.Key) -> URL? {
        if let urlString: String = decodeIfPresentIgnoringEmpty(key: key) {
            return URL(string: urlString)
        }
        
        return nil
    }
    
    public func decodeIfPresentIgnoringEmpty(key: KeyedDecodingContainer.Key, format: String) -> Date? {
        if let dateString: String = decodeIfPresentIgnoringEmpty(key: key) {
            return AppSettings.dateFormatter.date(from: dateString)
        }
        
        return nil
    }
}

extension Venue {
    enum CodingKeys: String, CodingKey {
        case name = "VenueName"
        case address = "VenueStreetName"
        case suburb = "VenueSuburb"
        case postcode = "VenuePostcode"
        case latitude = "VenueLatitude"
        case longitude = "VenueLongitude"
        case hasDisabledAccess = "VenueHasDisabledAccess"
    }
    
    public init(from decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = container.decodeIfPresentIgnoringEmpty(key: .name)
            self.address = container.decodeIfPresentIgnoringEmpty(key: .address)
            self.suburb = container.decodeIfPresentIgnoringEmpty(key: .suburb)
            self.postcode = container.decodeIfPresentIgnoringEmpty(key: .postcode)
            self.latitude  = container.decodeIfPresent(key: .latitude)
            self.longitude = container.decodeIfPresent(key: .longitude)
            self.hasDisabledAccess  = container.decodeIfPresent(key: .hasDisabledAccess)
        } catch {
            throw error
        }
    }
}

extension Event {
    enum CodingKeys: String, CodingKey {
        case id = "EventID"
        case name = "EventName"
        case start = "EventStart"
        case end = "EventEnd"
        case description = "EventDescription"
        case imageUrl = "EventOfficialImageUrl"
        case targetAudience = "EventTargetAudience"
        case payment = "EventPayment"
        case isFree = "EventIsFree"
        case additionalInfo = "EventMoreInfo"
        case contactName = "EventContactName"
        case contactOrganisation = "EventContactOrganisation"
        case contactPhone =  "EventContactTelephone"
        case contactEmail = "EventContactEmail"
        case bookingPhone = "EventBookingPhone"
        case bookingEmail = "EventBookingEmail"
        case bookingUrl = "EventBookingUrl"
        case facebook = "EventSocialFacebook"
        case twitter = "EventSocialTwitter"
        case website = "EventWebsite"
        case state = "EventState"
        case venue = "Venue"
    }
    
    public init(from decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.id = container.decodeIfPresentIgnoringEmpty(key: .id)
            self.name = container.decodeIfPresentIgnoringEmpty(key: .name)
            //self.start =
            //self.end =
            self.description = container.decodeIfPresentIgnoringEmpty(key: .description)
            self.imageUrl = container.decodeIfPresentIgnoringEmpty(key: .imageUrl)
            
            self.targetAudience = container.decodeIfPresent(key: .targetAudience)
            self.payment = container.decodeIfPresentIgnoringEmpty(key: .payment)
            self.isFree = container.decodeIfPresent(key: .isFree)
            self.additionalInfo = container.decodeIfPresent(key: .additionalInfo)
            
            self.contactName = container.decodeIfPresent(key: .contactName)
            self.contactOrganisation = container.decodeIfPresent(key: .contactOrganisation)
            self.contactPhone = container.decodeIfPresent(key: .contactPhone)
            self.contactEmail = container.decodeIfPresent(key: .contactEmail)
            
            self.bookingPhone = container.decodeIfPresentIgnoringEmpty(key: .bookingPhone)
            self.bookingEmail = container.decodeIfPresentIgnoringEmpty(key: .bookingEmail)
            self.bookingUrl = container.decodeIfPresentIgnoringEmpty(key: .bookingUrl)
            
            self.websiteUrl = container.decodeIfPresentIgnoringEmpty(key: .website)
            self.facebookUrl = container.decodeIfPresentIgnoringEmpty(key: .facebook)
            self.twitterUrl = container.decodeIfPresentIgnoringEmpty(key: .twitter)
            
            self.state = container.decodeIfPresent(key: .state)
            //self.venue =
        } catch {
            
            // log invalid XML object for diagnosis
            
            throw error
        }
    }
}
