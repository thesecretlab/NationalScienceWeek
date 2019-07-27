//
//  EventsList.swift
//  Science Week
//
//  Created by Mars Geldard on 24/6/19.
//  Copyright © 2019 Mars Geldard. All rights reserved.
//

import Foundation

extension XMLParserDelegate {
    
    func parseUpdates() {
        if let parser = XMLParser(contentsOf: URL.feedCacheURL) {
            parser.delegate = self
            parser.parse()
        }
    }
}

final class EventsList {
    private static let shared = EventsList()
    
    private var sharedEvents: [Event] = []
    private var sharedDelegate: XMLParserDelegate? = nil
    private var sharedFavouriteEventIDs: [String] = []
    
    static var delegate: XMLParserDelegate? {
        get { return EventsList.shared.sharedDelegate }
        set { EventsList.shared.sharedDelegate = newValue }
    }
    
    static var events: [Event] {
        get { return EventsList.shared.sharedEvents }
        set { EventsList.shared.sharedEvents = newValue }
    }
    
    static var favouriteEventIDs: [String] {
        get { return EventsList.shared.sharedFavouriteEventIDs }
        set { EventsList.shared.sharedFavouriteEventIDs = newValue }
    }
    
    private init() {
        EventsList.refresh()
    }
    
    static func addEvent(_ event: Event) {
        var event = event
        
        if favouriteEventIDs.contains(event.id) && !event.isFavourite {
            event.toggleFavourite()
        }
        
        self.events.append(event)
    }
    
    static func refresh() {
        FeedHandler.requestContent { data in
            if let data = data {
                
                // save it to disk
                do {
                    try data.write(to: URL.feedCacheURL)
                    
                    EventsList.events = []
                    
                    // when complete, update mainviewcontroller
                    EventsList.delegate?.parseUpdates()
                } catch let error {
                    print("Error writing data to disk: \(error)")
                }
                
            }
        }
    }
}
