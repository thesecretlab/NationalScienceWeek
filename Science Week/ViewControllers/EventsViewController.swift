//
//  EventsViewController.swift
//  Science Week
//
//  Created by Mars Geldard on 17/6/19.
//  Copyright © 2019 Mars Geldard. All rights reserved.
//

import UIKit

class EventsViewController: UITableViewController, EventDisplayingViewController {
    
    @IBOutlet var parentView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var favouritesButton: UIBarButtonItem!
    
    
    @IBAction func favouritesButtonPressed(_ sender: Any) {
        toggleFavouritesOnly()
    }
    
    private(set) var showFavouritesOnly = false
    private(set) var stateFilter: State? = nil
    
    private var displayedEvents: [Event] = EventsList.events
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTheme()
    }
    
    func refresh() {
        filterEvents(state: stateFilter, favouritesOnly: showFavouritesOnly)
    }
    
    private func toggleFavouritesOnly() {
        showFavouritesOnly = !showFavouritesOnly
    
        let statusMessage = showFavouritesOnly ? "Filtering by Favourites" : "Showing all"
        showToast(message: statusMessage)
        Logger.log(statusMessage)
        
        favouritesButton.tintColor = showFavouritesOnly ? Theme.primaryAccentColour : Theme.inactiveColour
        refresh()
    }
    
    private func setTheme() {
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: Theme.primaryTextColour]
        self.navigationController?.navigationBar.tintColor = Theme.primaryAccentColour
        self.navigationController?.navigationBar.barStyle = Theme.lightTheme ? .default : .black
        
        favouritesButton.tintColor = showFavouritesOnly ? Theme.primaryAccentColour : Theme.inactiveColour
        
        parentView?.backgroundColor = Theme.primaryBackgroundColour
        
        tableView.backgroundColor = Theme.primaryBackgroundColour
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Theme.lightTheme ? UIStatusBarStyle.default : .lightContent
    }

    internal func filterEvents(state: State?, favouritesOnly: Bool) {
        var events = EventsList.events
        
        if let stateCode = state {
            events = events.filter { event in event.state == stateCode || event.state == nil }
        }
        
        if favouritesOnly {
            events = events.filter { event in event.isFavourite }
        }
        
        displayedEvents = events
        tableView.reloadData()
    }
}

// MARK: UITableView functions

extension EventsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedEvents.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let event = displayedEvents[indexPath.item]
        let primary = "\(event.name)"
        let secondary = "\(event.venue?.name  ?? "Event Venue"), \(event.state?.code ?? "Nationwide")"
        
        let cellIdentifier = "EventTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) else {
            fatalError("Failed to dequeue cell with identifier \(cellIdentifier)")
        }
        
        cell.backgroundColor = .clear
        
        cell.textLabel?.textColor = Theme.primaryTextColour
        cell.detailTextLabel?.textColor = Theme.secondaryTextColour
        
        cell.textLabel?.text = primary
        cell.detailTextLabel?.text = secondary

        return cell
    }
}
