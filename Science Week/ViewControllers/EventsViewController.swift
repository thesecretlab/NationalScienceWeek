//
//  EventsViewController.swift
//  Science Week
//
//  Created by Mars Geldard on 17/6/19.
//  Copyright © 2019 Mars Geldard. All rights reserved.
//

import UIKit

class EventsViewController: UITableViewController, EventDisplayingViewController {
    
    @IBOutlet weak var favouritesButton: UIBarButtonItem!
    
    enum ListType {
        case allEvents, specifiedEvents
    }
    
    var listType : ListType = .allEvents
    
    
    enum EventGrouping : Int {
        case byDate, byTime
    }
    
    typealias EventGroup = (start: Date, events: [Event])
    
    var events : [Event] = []
    
    var states : [String] = []
    
    var grouping : EventGrouping = .byDate
    
    var displayedEventGroups : [EventGroup] = []
    
    private(set) var stateFilter: State? = nil
    
    private var displayedEvents: [Event] = EventsList.events
    
    lazy var headerDateFormatter : DateFormatter = {
        let d = DateFormatter()
        
        d.dateFormat = "EEEE, MMMM dd"
        
        return d
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTheme()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Events"
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        }
        definesPresentationContext = true
        
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = true
    }
    
    func refresh() {
        events = EventsList.events
        updateDisplayedEventGroups()
        
        tableView.reloadData()
    }
    
    func updateDisplayedEventGroups() {
        
        let searchText : String?
        
        if let t = searchController.searchBar.text, searchController.isActive, t.count > 0 {
            searchText = searchController.searchBar.text
        } else {
            searchText = nil
        }
        
        let filteredEvents = events.filter({( event : Event) -> Bool in
            
            
            // Do we have a search text?
            if let searchText = searchText {
                // Include it if the search text matches
                let matches = event.name.lowercased().contains(searchText.lowercased())
                
                if matches == false {
                    return false
                }
            }
            
            // Don't perform any more filtering if we're showing a subset of events
            if listType == ListType.specifiedEvents {
                return true
            }
            
            // If a state is selected, and the event has a state, and the
            // selected state is not the event's state, do not include it
            if let state = self.stateFilter,
                let eventState = event.state,
                state != eventState {
                return false
            }
            
            // Does this event have an ID, and we're only showing favourites?
            if Preferences.shared.displayMode == .favouritesOnly {
                let isFavourite = FavouriteEvents.shared.isFavourite(id: event.id)
                
                if isFavourite == false {
                    return false
                }
            }
            
            return true
        })
        
        let groupedDict = Dictionary(grouping: filteredEvents, by: { (event: Event) -> Date in
            
            switch (grouping) {
            case .byDate:
                return Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: event.start ?? Date.distantFuture)!
            case .byTime:
                return event.start ?? Date.distantFuture
            }
        })
        
        displayedEventGroups = groupedDict.keys.sorted().map { (date) -> EventGroup in
            return (start: date, events: groupedDict[date] ?? [])
        }
    }
    
    let searchController = UISearchController(searchResultsController: nil)
    
    
    @IBAction func favouritesButtonPressed(_ sender: Any) {

        let currentDisplayMode = Preferences.shared.displayMode
        
        let newDisplayMode : Preferences.DisplayMode
        
        let statusMessage : String
        
        switch currentDisplayMode {
            
        case .all:
            newDisplayMode = .favouritesOnly
            statusMessage = "Filtering by Favourites"
            
            refresh()
            
        case .favouritesOnly:
            newDisplayMode = .all
            statusMessage = "Showing all"
        }
        
        showToast(message: statusMessage)
        
        Preferences.shared.displayMode = newDisplayMode
        
        updateDisplayedEventGroups()
        
        tableView.reloadData()
    }
    
    private func updateFavouritesButtonAppearance() {
        switch Preferences.shared.displayMode {
        case .all:
            favouritesButton.tintColor = Theme.inactiveColour
        case .favouritesOnly:
            favouritesButton.tintColor = Theme.primaryAccentColour
        }
    }
    
    private func setTheme() {
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: Theme.primaryTextColour]
        self.navigationController?.navigationBar.tintColor = Theme.primaryAccentColour
        self.navigationController?.navigationBar.barStyle = Theme.lightTheme ? .default : .black
        
        updateFavouritesButtonAppearance()
        
        let bgView = UIView()
        bgView.backgroundColor = Theme.primaryBackgroundColour
        self.tableView.backgroundView = bgView
        
        tableView.backgroundColor = Theme.primaryBackgroundColour
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return Theme.lightTheme ? UIStatusBarStyle.default : .lightContent
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let cell = sender as? UITableViewCell, let indexPath = self.tableView.indexPath(for: cell) else {
            fatalError("Segue sender is not a cell, or index path for cell not found")
        }
        
        guard let detailViewController = segue.destination as? EventDetailViewController else {
            fatalError("Segue expected destination to be an EventDetailViewController")
        }
        
        let event = self.displayedEventGroups[indexPath.section].events[indexPath.row]
        
        detailViewController.event = event
    }
}

// MARK: UITableView functions

extension EventsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return displayedEventGroups.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedEventGroups[section].events.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerDateFormatter.string(from: displayedEventGroups[section].start)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "EventTableViewCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        let event = displayedEventGroups[indexPath.section].events[indexPath.row]
        
        let primary = "\(event.name)"
        let secondary = "\(event.venue?.name  ?? "Event Venue"), \(event.state?.code ?? "Nationwide")"
        
        cell.backgroundColor = .clear
        
        cell.textLabel?.textColor = Theme.primaryTextColour
        cell.detailTextLabel?.textColor = Theme.secondaryTextColour
        
        cell.textLabel?.text = primary
        cell.detailTextLabel?.text = secondary

        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        if let header = view as? UITableViewHeaderFooterView {
            header.backgroundColor = Theme.secondaryBackgroundColour
            header.textLabel?.textColor = Theme.primaryTextColour
        }
        
    }
}

extension EventsViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        updateDisplayedEventGroups()
        tableView.reloadData()
    }
}
