//
//  AppRepository.swift
//  SOS Zombies
//
//  Created by Achref Marzouki on 21/4/21.
//

import CoreData

class AppRepository: NSObject {
    
    // MARK: - Shared instance
    
    static let shared = AppRepository()
    
    // MARK: - Private
    
    private var refreshSucceeded = false
    
    // MARK: - Initialzers
    
    override private init() {
        super.init()
    }
    
    // MARK: - Public
    
    func refreshRemoteData(in context: NSManagedObjectContext, completion: @escaping (Bool) -> Void) {
        refreshSucceeded = true
        let group = DispatchGroup()
        refreshIllnesses(group: group, in: context)
        refreshHospitals(group: group, in: context)
        // completion
        group.notify(queue: .global()) {
            completion(self.refreshSucceeded)
        }
    }
    
    // MARK: - Private
    
    private func refreshIllnesses(limit: Int? = nil, page: Int? = nil, group: DispatchGroup, in context: NSManagedObjectContext) {
        group.enter()
        WSManager.shared.remoteDataForRoute(DataRouter.illnesses(limit: limit, page: page)) { response in
            if let jsonResponse = response {
                // illnesses
                if let result = jsonResponse[C.Keys.EMBEDDED] as? Json, let jsonArray = result[C.Keys.ILLNESSES] as? [Json] {
                    Illness.insertOrUpdate(fromJson: jsonArray, in: context)
                    context.saveContext()
                }
                // pagination
                let pagination = self.extractPagination(from: jsonResponse)
                if pagination.nextPage != -1 {
                    self.refreshIllnesses(limit: pagination.limit, page: pagination.nextPage, group: group, in: context)
                }
                self.refreshSucceeded = self.refreshSucceeded && true
                group.leave()
                
            } else {
                self.refreshSucceeded = false
                group.leave()
            }
        }
    }
    
    private func refreshHospitals(limit: Int? = nil, page: Int? = nil, group: DispatchGroup, in context: NSManagedObjectContext) {
        group.enter()
        WSManager.shared.remoteDataForRoute(DataRouter.hospitals(limit: limit, page: page)) { [self] response in
            if let jsonResponse = response {
                // hospitals
                if let result = jsonResponse[C.Keys.EMBEDDED] as? Json, let jsonArray = result[C.Keys.HOSPITALS] as? [Json] {
                    Hospital.insertOrUpdate(fromJson: jsonArray, in: context)
                    context.saveContext()
                }
                // pagination
                let pagination = self.extractPagination(from: jsonResponse)
                if pagination.nextPage != -1 {
                    self.refreshHospitals(limit: pagination.limit, page: pagination.nextPage, group: group, in: context)
                }
                self.refreshSucceeded = self.refreshSucceeded && true
                group.leave()
            } else {
                self.refreshSucceeded = false
                group.leave()
            }
        }
    }
    
    // MARK: - Helpers
    
    private func extractPagination(from jsonResponse: Json) -> (limit: Int, nextPage: Int) {
        let pagination = jsonResponse[C.Keys.PAGE] as? Json
        let currentPage = pagination?[C.Keys.NUMBER] as? Int ?? 0
        let totalPages = pagination?[C.Keys.TOTAL_PAGES] as? Int ?? 0
        let limit = pagination?[C.Keys.SIZE] as? Int ?? 0
        var nextPage = currentPage + 1
        nextPage = nextPage > totalPages ? -1 : nextPage
        return (limit, nextPage)
    }
}
