//
//  UITests.swift
//  SOS ZombiesUITests
//
//  Created by Achref Marzouki on 21/4/21.
//

import XCTest

class UITests: XCTestCase {
    
    // MARK: - Properties
    
    private var allowLocation = true
    
    // MARK: - Lifecycle
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        
        // handle interruptions
        addUIInterruptionMonitor(withDescription: "Handle no registrations alert") { (element) -> Bool in
            let okButton = element.buttons["OK"].firstMatch
            if element.elementType == .alert && okButton.exists {
                okButton.tap()
                return true
            }
            
            return false
        }
        
        // handle location acess alert
        addUIInterruptionMonitor(withDescription: "Handle location acess alert") { (element) -> Bool in
            let allowButton = element.buttons["Allow While Using App"]
            let denyButton = element.buttons["Don't Allow"]
            if element.elementType == .alert {
                if self.allowLocation && allowButton.exists {
                    allowButton.tap()
                    return true
                } else if !self.allowLocation && denyButton.exists {
                    denyButton.tap()
                    return true
                }
            }
            
            return false
        }
    }

    func testRegistrationFail() throws {
        let app = XCUIApplication()
        app.launch()
        // new registration
        app.navigationBars["Registrations"].buttons["Add"].tap()
        // choose illness
        app.tables.staticTexts["Whispering Hepatitis"].tap()
        // tap the button without any information
        app.buttons["Register now"].tap()
        // make sure there is an error regarding the user name
        let errorText = app.staticTexts["The name field is required"]
        XCTAssert(errorText.exists)
    }
    
    func testRegistrationSuccess() throws {
        let app = XCUIApplication()
        app.launch()
        // register
        registerUser("Achref Marzouki", insuranceID: "abc123", illness: "Whispering Hepatitis", painLevel: "1", in: app)
        // make sure the registration is complete
        let suggestedHospitals = app.staticTexts["Suggested Hospitals"].firstMatch
        let suggestedHospitalsExists = suggestedHospitals.waitForExistence(timeout: 1)
        XCTAssert(suggestedHospitalsExists)
    }
    
    func testRegistrationShowsUpInHoneScreen() throws {
        let app = XCUIApplication()
        app.launch()
        // register
        registerUser("Sheree Carter", insuranceID: "666777888", illness: "Whispering Hepatitis", painLevel: "2", in: app)
        // make sure the registration is complete
        let suggestedHospitals = app.staticTexts["Suggested Hospitals"].firstMatch
        let suggestedHospitalsExists = suggestedHospitals.waitForExistence(timeout: 1)
        XCTAssert(suggestedHospitalsExists)
        // tap done button to go back to the hone view
        app.navigationBars.firstMatch.buttons["Done"].tap()
        // make sure the registration is in the list
        let registration = app.tables.cells.containing(.staticText, identifier:"Whispering Hepatitis").element
        XCTAssertTrue(registration.exists)
    }
    
    @available(iOS 13.4, *)
    func testLocationGranted() {
        let app = XCUIApplication()
        app.resetAuthorizationStatus(for: .location)
        app.launch()
        // register
        registerUser("Sébastien Cortello", insuranceID: "123456789", illness: "Intense Intolerance", painLevel: "3", in: app)
        // tap filter button
        app.navigationBars.firstMatch.buttons["Waiting Time"].tap()
        let sortByDistance = app.sheets.buttons["Sort by distance"]
        // make sure the sort by distance button is enabled
        XCTAssert(sortByDistance.isEnabled)
    }
    
    @available(iOS 13.4, *)
    func testLocationDenied() {
        allowLocation = false
        let app = XCUIApplication()
        app.resetAuthorizationStatus(for: .location)
        app.launch()
        // register
        registerUser("Latetia Muller", insuranceID: "987654321", illness: "Happy Euphoria", painLevel: "4", in: app)
        // tap filter button
        app.navigationBars.firstMatch.buttons["Waiting Time"].tap()
        let sortByDistance = app.sheets.buttons["Sort by distance"]
        // make sure the sort by distance button is disabled
        XCTAssertFalse(sortByDistance.isEnabled)
    }
    
    // MARK: - Helpers
    
    func registerUser(_ user: String, insuranceID: String = "", illness: String, painLevel: String = "0", in app: XCUIApplication) {
        // new registration
        app.navigationBars.firstMatch.buttons["Add"].tap()
        // choose illness
        app.tables.staticTexts[illness].tap()
        // populate the form
        app.textFields["John Doe"].tap()
        app.textFields["John Doe"].typeText(user)
        app.textFields["Optional"].tap()
        app.textFields["Optional"].typeText(insuranceID)
        app.buttons[painLevel].tap()
        // tap the register button
        app.buttons["Register now"].tap()
        
        // handle alert if exisiting
        let alert = app.sheets["Existing record found"].firstMatch
        let alertExists = alert.waitForExistence(timeout: 1)
        if alertExists {
            alert.buttons["Continue"].tap()
        }
    }
}
