//
//  FavouriteEvents.swift
//  Science Week
//
//  Created by Jon Manning on 28/7/19.
//  Copyright © 2019 Secret Lab. All rights reserved.
//

import Foundation

public class Preferences {
    public static let shared = Preferences()
}

extension Preferences {
    
    public enum DisplayMode : Int {
        case all, favouritesOnly
    }
    
    private static let displayModeKey = "display_mode"
    
    public var displayMode : DisplayMode {
        get {
            return DisplayMode(rawValue: UserDefaults.standard.integer(forKey: Preferences.displayModeKey)) ?? .all
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Preferences.displayModeKey)
        }
    }
}

public class FavouriteEvents {
    
    private static let eventsKey = "favourite_events"
    
    public static let shared = FavouriteEvents()
    
    private lazy var eventList : Set<String> = {
        
        guard let data = UserDefaults.standard.data(forKey: FavouriteEvents.eventsKey) else {
            return []
        }
        
        do {
            let list = try JSONDecoder().decode([String].self, from: data)
            
            return Set(list)
        } catch {
            return []
        }
        
    }()
    
    public func isFavourite(id: String) -> Bool {
        return eventList.contains(id)
    }
    
    public func add(id: String) {
        eventList.insert(id)
        save()
    }
    
    public func remove(id: String) {
        eventList.remove(id)
        save()
    }
    
    public func save() {
        do {
            let data = try JSONEncoder().encode(eventList)
            
            UserDefaults.standard.set(data, forKey: FavouriteEvents.eventsKey)
        } catch {
            NSLog("Failed to save favourites list: \(error)")
        }
        
    }
    
    public func removeMissing(available: [String]) {
        let availableSet = Set(available)
        
        // Include only event IDs that are 1. in the favourite set and 2. in
        // the available set.
        eventList = eventList.intersection(availableSet)
        save()
    }
    
}

extension Preferences {
    
    static let stateKey = "state"
    
    var selectedState : String? {
        get {
            return UserDefaults.standard.string(forKey: Preferences.stateKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Preferences.stateKey)
        }
    }
    
}
