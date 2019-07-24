//
//  ViewController.swift
//  Science Week
//
//  Created by Mars Geldard on 28/3/19.
//  Copyright © 2019 Mars Geldard. All rights reserved.
//

import UIKit
import MapKit

enum TabContent {
    case events, detail, map, about
}

class MasterViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTheme()
    }
    
    private func setTheme() {
        tabBar.setBackgroundColor(colour: Theme.primaryBackgroundColour)
        tabBar.tintColor = Theme.primaryAccentColour
        tabBar.barStyle = Theme.lightTheme ? .default : .black
        tabBar.unselectedItemTintColor = Theme.secondaryAccentColour
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Theme.lightTheme ? UIStatusBarStyle.default : .lightContent
    }
}
