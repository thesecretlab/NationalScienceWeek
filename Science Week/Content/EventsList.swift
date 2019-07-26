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
        if let parser = XMLParser(contentsOf: AppSettings.cachePath) {
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
        EventsList.refresh()
    }
    
    static func addEvent(event: Event) {
        self.events.append(event)
    }
    
    static func refresh() {
        FeedHandler.requestContent { data in
            if let data = data {
                
                
                print(data)
                
                // save it to disk
        
                
                // when complete, update mainviewcontroller
                EventsList.events = []
                EventsList.delegate?.parseUpdates()
            }
        }
    }
}
