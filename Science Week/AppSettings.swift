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
    static var primaryBackgroundColour  = UIColour.black
    static let primaryAccentColour      = UIColour(r: 255, g: 000, b: 164)
    static let secondaryAccentColour    = UIColour(r: 182, g: 032, b: 224)
    static let tertiaryAccentColour     = UIColour(r: 109, g: 212, b: 000)
    static let inactiveColour           = UIColour.darkGray
    
    // 2018 colours
//    static let lightTheme = true
//    static var primaryBackgroundColour  = UIColour(hex: "#18655C")
//    static let primaryAccentColour      = UIColour(hex: "#FFFFFF")
//    static let secondaryAccentColour    = UIColour(hex: "#fbaf59")
//    static let tertiaryAccentColour     = UIColour(hex: "#f26659")
//    static let inactiveColour           = UIColour.gray
    
    static var mapAnnotationColour = Theme.primaryAccentColour
    
    //=====================================
    // ^^^ EDIT HERE TO CHANGE THEME ^^^
    //=====================================
    
    
    // unchanging values
    static let primaryTextColour = Theme.lightTheme ? UIColour.black : .white
    static var secondaryTextColour = UIColour.gray
    static var secondaryBackgroundColour: UIColour {
        if Theme.lightTheme {
            return primaryBackgroundColour.darkened(by: 30)
        }
        
        return primaryBackgroundColour.lightened(by: 30)
    }
    
    private init() {}
}

// MARK: Semantics

extension URL {
    static var scienceWeekURL = URL(string: "https://www.scienceweek.net.au/")!
    static var scienceWeekMenuURL = URL(string: "https://www.scienceweek.net.au/#")!
    static let rssFeedURL = URL(string: "https://www.scienceweek.net.au/event-transfer/scienceweek-events.xml")!
    static let cacheURL = try! FileManager
        .default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent("Feed.xml")
}

public final class AppSettings {
    
    // appears in default event names and view titles
    static let year: Int = 2019
    
    // dictates how dates are ingested from XML feed
    static let headerDateFormat = "E, d MMM yyyy HH:mm:ss zzz"
    static let feedDateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    
    private init() {}
}
