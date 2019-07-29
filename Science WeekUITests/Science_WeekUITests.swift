//
//  Science_WeekUITests.swift
//  Science WeekUITests
//
//  Created by Jonathon Manning on 28/7/19.
//  Copyright © 2019 Mars Geldard. All rights reserved.
//

import XCTest

class Science_WeekUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSnapshot() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        //snapshot("0_Events")
        //XCUIApplication().tables.firstMatch.tableRows.firstMatch.tap()
        
        
        snapshot("1-EventList")
        let app = XCUIApplication()
        app.tables.cells.staticTexts["Trash Robot"].tap()
        
        snapshot("2-EventDetail")
        
        addUIInterruptionMonitor(withDescription: "Location Services") {
            (alert) -> Bool in
            
            print("Interrupted!")
            
            if alert.buttons["Allow"].exists {
                alert.buttons["Allow"].tap()
                print("Tapping Allow!")
            }
            return true
        }
        
        app.tabBars.buttons["Map"].tap()
        
//        let allowBtn = springboard.buttons["Allow"]
//        if allowBtn.exists {
//            allowBtn.tap()
//        }
        
        snapshot("3-Map")
        
        
    }

}
