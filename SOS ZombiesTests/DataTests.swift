//
//  DataTests.swift
//  SOS ZombiesTests
//
//  Created by Achref Marzouki on 22/4/21.
//

import XCTest
@testable import SOS_Zombies

class DataTests: XCTestCase {

    // MARK: - Properties
        
    private let networkMonitor = NetworkMonitor.shared
    private var coreDataManager: CoreDataManagerTest!
    private var repository: AppRepository!
    
    // MARK: - Lifecycle
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        coreDataManager = CoreDataManagerTest.shared
        repository = AppRepository.shared
    }

    override func tearDownWithError() throws {
        coreDataManager = nil
        repository = nil
        try super.tearDownWithError()
    }

    // MARK: - Tests
    
    func testCoreDataManager() throws {
        XCTAssertNotNil(coreDataManager.managedContext)
        XCTAssertNotNil(coreDataManager.managedObjectModel)
    }
    
    func testRemoteDataSync() throws {
        try XCTSkipUnless(networkMonitor.isReachable, "Network connectivity is required for this test.")
        let context = coreDataManager.managedContext
        repository.refreshRemoteData(in: context) { success in
            // save
            context.saveContext()
            // illnesses
            let illnesses = Illness.all(in: context)
            XCTAssertEqual(illnesses.count, 15)
            // hospitals
            let hospitals = Hospital.all(in: context)
            XCTAssertEqual(hospitals.count, 23)
        }
    }
}
