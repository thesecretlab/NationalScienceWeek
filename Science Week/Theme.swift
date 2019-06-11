//
//  Theme.swift
//  Science Week
//
//  Created by Mars Geldard on 29/3/19.
//  Copyright © 2019 Mars Geldard. All rights reserved.
//

import UIKit

extension UIColor {
    
    // 2019 colours
    static var lightBackgroundColor = UIColor.white
    static var darkBackgroundColor  = UIColor.black
    static let primaryAccentColor   = UIColor(r: 255, g: 000, b: 164)
    static let secondaryAccentColor = UIColor(r: 109, g: 212, b: 000)
    static let tertiaryAccentColor  = UIColor(r: 182, g: 032, b: 224)
    
    // 2018 colours
    // static var lightBackgroundColor = UIColor.white
    // static var darkBackgroundColor  = UIColor.black
    // static let primaryAccentColor   = UIColor(r: 024, g: 101, b: 092)
    // static let secondaryAccentColor = UIColor(r: 251, g: 175, b: 089)
    // static let tertiaryAccentColor  = UIColor(r: 242, g: 102, b: 089)
    
    
    convenience init(r red: CGFloat, g green: CGFloat, b blue: CGFloat, a alpha: CGFloat = 1.0 ) {
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
