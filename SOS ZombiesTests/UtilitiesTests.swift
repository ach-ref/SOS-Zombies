//
//  UtilitiesTests.swift
//  SOS ZombiesTests
//
//  Created by Achref Marzouki on 22/4/21.
//

import XCTest
@testable import SOS_Zombies

class UtilitiesTests: XCTestCase {
    
    // MARK: - Properties
    
    // MARK: - Lifecycle
    
    override func setUpWithError() throws {
        try super.setUpWithError()
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }
    
    // MARK: - Tests
    
    func testUserFriendlyTime() throws {
        // the locale for the test target is set to EN_AUS
        let timeInterval: Int16 = 120
        let aString = timeInterval.userFriendlyTime
        XCTAssertEqual(aString, "2 hour(s)")
    }
    
    func testTrimmedStrings() throws {
        // trimmed string
        XCTAssertFalse("\t        a     ".trimmed().isEmpty)
        XCTAssertTrue("  \n\t    \t\n      ".trimmed().isEmpty)
    }
}
