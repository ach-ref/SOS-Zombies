//
//  SlowTests.swift
//  SOS ZombiesTests
//
//  Created by Achref Marzouki on 21/4/21.
//

import XCTest
@testable import SOS_Zombies

class SlowTests: XCTestCase {

    // MARK: - Properties
        
    private let networkMonitor = NetworkMonitor.shared
    private var sut: URLSession!
    
    // MARK: - Lifecycle
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = URLSession(configuration: .default)
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    // MARK: - Tests
    
    func testRoutable() {
        XCTAssertNoThrow(DataRouter.illnesses(limit: nil, page: nil))
        XCTAssertNoThrow(DataRouter.hospitals(limit: 20, page: nil))
    }
    
    func testValidApiCallsGetStatusCode200() throws {
        try XCTSkipUnless(networkMonitor.isReachable, "Network connectivity is required for this test.")
        let url = URL(string: "http://dmmw-api.australiaeast.cloudapp.azure.com:8080/illnesses")!
        let promise = expectation(description: "Status code: 200")
        var statusCode: Int?
        var responseError: Error?
        let dataTask = sut.dataTask(with: url) { _, response, error in
            statusCode = (response as? HTTPURLResponse)?.statusCode
            responseError = error
            promise.fulfill()
        }
        dataTask.resume()
        wait(for: [promise], timeout: 5)
        
        XCTAssertNil(responseError)
        XCTAssertEqual(statusCode, 200)
    }

}
