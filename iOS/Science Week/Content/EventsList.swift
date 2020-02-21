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
        
        let url : URL
        
        if FileManager.default.fileExists(atPath: URL.feedCacheURL.path) {
            NSLog("Reading events data from cache.")
            url = URL.feedCacheURL
        } else {
            NSLog("Reading events from built-in data")
            url = URL.builtInDataURL
            
        }
        
        if let parser = XMLParser(contentsOf: url) {
            parser.delegate = self
            parser.parse()
        }
    }
}

final class EventsList {
    private static let shared = EventsList()
    
    private var sharedEvents: [Event] = []
    private var sharedDelegate: XMLParserDelegate? = nil
    
    static var delegate: XMLParserDelegate? {
        get { return EventsList.shared.sharedDelegate }
        set { EventsList.shared.sharedDelegate = newValue }
    }
    
    static var events: [Event] {
        get { return EventsList.shared.sharedEvents }
        set { EventsList.shared.sharedEvents = newValue }
    }
    
    private init() {
        
    }
    
    static func addEvent(_ event: Event) {
        self.events.append(event)
    }
    
    static func refreshFromCache() {
        EventsList.events = []
        EventsList.delegate?.parseUpdates()
    }
    
    static func refreshFromNetwork() {
        
        
        
        FeedHandler.requestContent { data in
            NSLog("Finished loading data.")
            if let data = data {
                
                // save it to disk
                do {
                    try data.write(to: URL.feedCacheURL)
                    
                    NSLog("Wrote data to cache.")
                    
                    EventsList.events = []
                    
                    // when complete, update mainviewcontroller
                    EventsList.delegate?.parseUpdates()
                    
                    NSLog("Finished parsing event data.")
                } catch let error {
                    print("Error writing data to disk: \(error)")
                }
                
            }
        }
    }
}
