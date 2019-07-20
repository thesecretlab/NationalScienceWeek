//
//  AppSettings.swift
//  Science Week
//
//  Created by Mars Geldard on 11/6/19.
//  Copyright © 2019 Mars Geldard. All rights reserved.
//

import Foundation
import UIKit

// MARK: Colour and Theme

typealias UIColour = UIColor

public final class Theme {
    
    // 2019 colours
    static let lightTheme = false
    static var primaryBackgroundColour   = UIColor.black
    static let primaryAccentColour = UIColor(r: 255, g: 000, b: 164)
    static let secondaryAccentColour = UIColor(r: 182, g: 032, b: 224)
    static let tertiaryAccentColour = UIColor(r: 109, g: 212, b: 000)
    
    // 2018 colours
//    static let lightTheme = true
//    static var mainBackgroundColour         = UIColor(hex: "#18655C")
//    static var secondaryBackgroundColour    = UIColor(hex: "#000000")
//    static let primaryAccentColour          = UIColor(hex: "#FFFFFF")
//    static let secondaryAccentColour        = UIColor(hex: "#fbaf59")
//    static let tertiaryAccentColour         = UIColor(hex: "#f26659")
    
    // unchanging values
    static let primaryTextColour = Theme.lightTheme ? UIColor.black : .white
    static var secondaryBackgroundColour: UIColor {
        if Theme.lightTheme {
            return primaryBackgroundColour.darkened(by: 30)
        }
        
        return primaryBackgroundColour.lightened(by: 30)
    }
    static var secondaryTextColour =  UIColor.gray
    
    private init() {}
}

// MARK: Semantics

extension URL {
    // the URL the 'About' tab points to
    static let scienceWeekURL = URL(string: "https://www.scienceweek.net.au/")!
}

public final class AppSettings {
    
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
