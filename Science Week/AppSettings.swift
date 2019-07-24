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
    
    
    //=====================================
    // vvv EDIT HERE TO CHANGE THEME vvv
    //=====================================
    
    
    // 2019 colours
    static let lightTheme = false
    static var primaryBackgroundColour  = UIColor.black
    static let primaryAccentColour      = UIColor(r: 255, g: 000, b: 164)
    static let secondaryAccentColour    = UIColor(r: 182, g: 032, b: 224)
    static let tertiaryAccentColour     = UIColor(r: 109, g: 212, b: 000)
    static let inactiveColour           = UIColor.darkGray
    
    // 2018 colours
//    static let lightTheme = true
//    static var primaryBackgroundColour  = UIColor(hex: "#18655C")
//    static let primaryAccentColour      = UIColor(hex: "#FFFFFF")
//    static let secondaryAccentColour    = UIColor(hex: "#fbaf59")
//    static let tertiaryAccentColour     = UIColor(hex: "#f26659")
//    static let inactiveColour           = UIColor.gray
    
    
    //=====================================
    // ^^^ EDIT HERE TO CHANGE THEME ^^^
    //=====================================
    
    
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
    static var scienceWeekURL = URL(string: "https://www.scienceweek.net.au/")!
    static var scienceWeekMenuURL = URL(string: "https://www.scienceweek.net.au/#")!
    static let rssFeedURL = URL(string: "https://www.scienceweek.net.au/event-transfer/scienceweek-events.xml")!
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
