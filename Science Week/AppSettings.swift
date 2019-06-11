//
//  AppSettings.swift
//  Science Week
//
//  Created by Mars Geldard on 11/6/19.
//  Copyright © 2019 Mars Geldard. All rights reserved.
//

import Foundation

public class AppSettings {
    
    // appears in default event names and view titles
    static let year: Int = 2019
    
    // dictates how dates are ingested from XML feed
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }()
    
    private init() {}
}

//: !!!
//: TODO: (Events.swift) Group Duplicate Events
//: !!!

//if self.state == nil, let venue = self.venue {
    // attempt to infer state by looking at venue address?
//}


// remove from categories "Science & Technology ~ " prefix

// UTF-8 encoding

// urls

// check if venue lat/long in Australia?
