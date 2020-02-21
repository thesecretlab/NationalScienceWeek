//
//  StateSelectionTableViewController.swift
//  ScienceWeek
//
//  Created by Jon Manning on 28/7/19.
//  Copyright © 2019 Secret Lab. All rights reserved.
//
//  This file is released under the terms of the MIT License.
//  Please see LICENSE.md in the root directory.

import UIKit

class StateSelectionTableViewController: UITableViewController {
    
    /// The list of states
    var states : [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var noStateSelectedString = "All States"
    
    /// The currently selected state
    var selectedState : String? {
        willSet {
            guard let selectedState = newValue else { return }
            
            if states.contains(selectedState) == false {
                self.selectedState = nil
            }
        }
    }
    
    
    
    /// Called when a selection is made.
    var didSelect : (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // For popovers, calculate the rectangle needed to
        // display the entire set of states, and declare that
        // to be our preferred size
        
        var size = tableView.rect(forSection: 0).size
        size.width = 0 // use default size
        
        self.preferredContentSize = size
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return states.count + 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StateCell", for: indexPath)

        let state : String?
        
        if indexPath.row > 0 {
            state = states[indexPath.row - 1]
            cell.textLabel?.text = state
        } else {
            state = nil
            cell.textLabel?.text = noStateSelectedString
        }
        
        if selectedState == state {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        cell.backgroundColor = .clear
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = Theme.secondaryAccentColourDark
        cell.selectedBackgroundView = bgColorView
    
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let thisState : String?
        
        if indexPath.row >= 1 {
            thisState = states[indexPath.row - 1]
        } else {
            thisState = nil
        }
        
        selectedState = thisState
        
        
        self.dismiss(animated: true, completion: nil)
        didSelect?()
        
    }


}
