//
//  ViewController.swift
//  Science Week
//
//  Created by Mars Geldard on 28/3/19.
//  Copyright © 2019 Mars Geldard. All rights reserved.
//

import UIKit
import MapKit

protocol EventDisplayingViewController {
    func refresh()
}

class MasterViewController: UITabBarController {
    
    private(set) var elementName: String = ""
    private(set) var currentEvent: Event = Event()
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        // example: 2019-08-11T15:00:00
        formatter.dateFormat = AppSettings.feedDateFormat
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        EventsList.delegate = self
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

extension MasterViewController: XMLParserDelegate {
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        self.elementName = elementName
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "Event" {
            currentEvent.validate()
            EventsList.addEvent(event: currentEvent)
            print(currentEvent)
            currentEvent = Event()
        } else if elementName == "Events" {
            DispatchQueue.main.async {
                if let displayingViewController = self.selectedViewController as? EventDisplayingViewController {
                    displayingViewController.refresh()
                }
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if data.isEmpty { return }
        
        switch elementName {
            case "EventID": currentEvent.id = data
            case "EventName": currentEvent.name = data
            case "EventType": currentEvent.type = data
            case "EventCategory": currentEvent.categories.append(data)
            //case "EventStart":
            //case "EventEnd":
            case "EventDescription": currentEvent.description = data
            //case "EventTargetAudience":
            case "EventPayment": currentEvent.payment = data
            //case EventIsFree":
            case "EventContactName": currentEvent.contact?.name = data
            //case "EventContactOrganisation":
            //case "EventContactTelephone":
            //case "EventContactEmail":
            case "EventWebsite": currentEvent.website = data
            case "EventState": currentEvent.state = State(rawValue: data.lowercased())
            case "EventMoreInfo": currentEvent.moreInfo = data
            //case "EventBookingPhone":
            //case "EventBookingUrl": currentEvent.bookingUrl = data
            //case "EventBookingEmail": currentEvent.bookingEmail = data
            //case "EventSocialFacebook": currentEvent.facebook = data
            //case "EventSocialTwitter": currentEvent.twitter = data
            //case "Venue":
            case "Attractions": currentEvent.attractions.append(data)
            //case "EventOfficialImageUrl":
            default: break
        }
    }
}
