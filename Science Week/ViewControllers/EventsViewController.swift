//
//  EventsViewController.swift
//  Science Week
//
//  Created by Mars Geldard on 17/6/19.
//  Copyright © 2019 Mars Geldard. All rights reserved.
//

import UIKit

extension UIImage {
    //static let filledHeartIcon = UIImage(named: <#T##String#>)
}

class EventsViewController: UIViewController {
    
    @IBOutlet var parentView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var favouritesButton: UIBarButtonItem!
    
    @IBAction func favouritesButtonPressed(_ sender: Any) {
        toggleFavouritesOnly()
    }
    
    private(set) var showFavouritesOnly = false
    private(set) var stateFilter: State? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTheme()
    }
    
    private func toggleFavouritesOnly() {
        showFavouritesOnly = !showFavouritesOnly
    
        let statusMessage = showFavouritesOnly ? "Filtering by Favourites" : "Showing all"
        showToast(message: statusMessage)
        Logger.log(statusMessage)
        
        favouritesButton.tintColor = showFavouritesOnly ? Theme.primaryAccentColour : Theme.inactiveColour
    }
    
    private func setTheme() {
        navigationBar.titleTextAttributes = [.foregroundColor: Theme.primaryTextColour]
        navigationBar.tintColor = Theme.primaryAccentColour
        favouritesButton.tintColor = showFavouritesOnly ? Theme.primaryAccentColour : Theme.inactiveColour
        navigationBar.barStyle = Theme.lightTheme ? .default : .black
        parentView.backgroundColor = Theme.primaryBackgroundColour
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Theme.lightTheme ? UIStatusBarStyle.default : .lightContent
    }
}

class EventsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var parentView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    private var displayedEvents: [Event] = EventsList.events
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTheme()
        
        tableView.delegate  = self
        tableView.dataSource = self
    }
    
    private func setTheme() {
        tableView.backgroundColor = Theme.primaryBackgroundColour
    }
    
    internal func filterEvents(state: State, favouritesOnly: Bool) {
        displayedEvents = EventsList.events.filter { event in event.isFavourite }
    }
}

// MARK: UITableView functions

extension EventsTableViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let event = displayedEvents[indexPath.item]
        let primary = event.name ?? "Event Name"
        let secondary = event.venue.name  ?? "Event Venue"
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "EventTableViewCell")
        cell.backgroundColor = .clear
        
        cell.textLabel?.textColor = Theme.primaryTextColour
        cell.detailTextLabel?.textColor = Theme.secondaryTextColour
        
        cell.textLabel?.text = primary
        cell.detailTextLabel?.text = secondary

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = displayedEvents[indexPath.item]
        showToast(message: "Event selected: \(event.name ?? "Event Name")")
    }
}
