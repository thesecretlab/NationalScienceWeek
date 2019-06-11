//
//  Decoding.swift
//  Science Week
//
//  Created by Mars Geldard on 11/6/19.
//  Copyright © 2019 Mars Geldard. All rights reserved.
//

extension KeyedDecodingContainer {
    public func decodeIfPresent<T: Decodable>(key: KeyedDecodingContainer.Key, default defaultValue: T? = nil) -> T? {
        let value = try? decodeIfPresent(T.self, forKey: key)
        return value ?? defaultValue
    }
    
    public func decodeIfPresent<T: Decodable>(key: KeyedDecodingContainer.Key, default defaultValue: T) -> T {
        let value = try? decodeIfPresent(T.self, forKey: key)
        return value ?? defaultValue
    }
    
    public func decodeIfPresentIgnoringEmpty<T: Decodable>(key: KeyedDecodingContainer.Key, default defaultValue: T? = nil) -> T? where T: Collection {
        let value = try? decodeIfPresent(T.self, forKey: key)
        return (value?.isEmpty ?? true) ? defaultValue : value
    }
    
    public func decodeIfPresentIgnoringEmpty<T: Decodable>(key: KeyedDecodingContainer.Key, default defaultValue: T) -> T where T: Collection {
        let value = try? decodeIfPresent(T.self, forKey: key)
        if let value = value {
            return value.isEmpty ? defaultValue : value
        }
        return defaultValue
    }
}

extension VenueDetails {
    private enum CodingKeys: String, CodingKey {
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
            
            //self.name = container.decodeIfPresentIgnoringEmpty(key: .name)
            //self.address =
            //self.suburb =
            //self.postcode =
            //self.latitude =
            //self.longitude =
            
            // get VenueLatitude and VenueLongitude as Float values, if they exist
            let latitude: Float? = container.decodeIfPresent(key: .latitude, default: nil)
            let longitude: Float? = container.decodeIfPresent(key: .longitude, default: nil)
            
            // if both existed and are valid
            if let lat = latitude, let long = longitude {
                
                // check they're in Australia?
                
                self.location = (lat, long)
            }
            
            // get VenueHasDisabledAcess as Boolean value, else default to false
            self.hasDisabledAccess  = container.decodeIfPresent(key: .hasDisabledAccess, default: false)
        } catch {
            
            // log invalid XML object for diagnosis
            
            throw error
        }
    }
}

extension Event {
    private enum CodingKeys: String, CodingKey {
        case id = "EventID"
        case name = "EventName"
        case start = "EventStart"
        case end = "EventEnd"
        case description = "EventDescription"
        case targetAudience = "EventTargetAudience"
        case payment = "EventPayment"
        case isFree = "EventIsFree"
        case category = "EventCategory"
        case contactName = "EventContactName"
        case contactOrganisation = "EventContactOrganisation"
        case contactTelephone =  "EventContactTelephone"
        case contactEmail = "EventContactEmail"
        case bookingEmail = "EventBookingEmail"
        case bookingUrl = "EventBookingUrl"
        case facebook = "EventSocialFacebook"
        case twitter = "EventSocialTwitter"
        case bookingPhone = "EventBookingPhone"
        case website = "EventWebsite"
        case state = "EventState"
        case moreInfo = "EventMoreInfo"
        case imageUrl = "EventOfficialImageUrl"
        case venue = "Venue"
    }
    
    public init(from decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            //self.id = container.decodeIfPresentIgnoringEmpty(key: .id)
            //self.name =
            //self.start =
            //self.end =
            //self.description =
            
            //self.targetAudience = container.decodeIfPresent(key: .targetAudience, default: TargetAudience.allAges)
            
            self.payment = container.decodeIfPresent(key: .payment, default: nil)
            self.isFree = container.decodeIfPresent(key: .isFree, default: false)
            
            //self.categories =
            //self.state =
            //self.additionalInformation =
            //self.imageUrl =
            //self.contactDetails =
            //self.bookingDetails =
            //self.socialDetails =
            //self.venueDetails =
            
            // remove from categories "Science & Technology ~ " prefix
            // UTF-8 encoding
            // urls
            // if self.state == nil
            // -> look at venue address
            
        } catch {
            
            // log invalid XML object for diagnosis
            
            throw error
        }
    }
}
