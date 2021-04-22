//
//  Illness+CoreDataClass.swift
//  SOS Zombies
//
//  Created by Achref Marzouki on 21/4/21.
//
//

import Foundation
import CoreData

@objc(Illness)
public class Illness: NSManagedObject {

    // MARK: - Public
    
    class func illnessNamed(_ illnessName: String, in context: NSManagedObjectContext) -> Illness? {
        var illness: Illness?
        context.performAndWait {
            let request: NSFetchRequest = fetchRequest()
            request.predicate = NSPredicate(format: "%K == %@", #keyPath(name), illnessName)
            request.fetchLimit = 1
            if let result = try? context.fetch(request) {
                illness = result.first
            }
        }
        return illness
    }
    
    class func all(in context: NSManagedObjectContext) -> [Illness] {
        var illnesses: [Illness] = []
        context.performAndWait {
            let request: NSFetchRequest = fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: #keyPath(id), ascending: true)]
            if let result = try? context.fetch(request) {
                illnesses = result
            }
        }
        return illnesses
    }
    
    class func insertOrUpdate(fromJson jsonList: [Json], in conext: NSManagedObjectContext) {
        let ids = jsonList.compactMap { ($0[C.Keys.ILLNESS] as? Json)?[C.Keys.ID] as? Int64 }
        let exisitingRecords = existingRecords(for: ids, in: conext)
        jsonList.forEach {
            if let jsonIllness = $0[C.Keys.ILLNESS] as? Json {
                let id = jsonIllness[C.Keys.ID] as? Int64 ?? 0
                if let existing = exisitingRecords[id] {
                    existing.update(from: jsonIllness, in: conext)
                } else {
                    insert(from: jsonIllness, in: conext)
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private class func existingRecords(for ids: [Int64], in context: NSManagedObjectContext) -> [Int64 : Illness] {
        var resultDict: [Int64 : Illness] = [:]
        context.performAndWait {
            let request: NSFetchRequest = fetchRequest()
            request.predicate = NSPredicate(format: "%K IN %@", #keyPath(id), ids)
            if let result = try? context.fetch(request) {
                resultDict = result.reduce(into: [Int64 : Illness]()) { $0[$1.id] = $1 }
            }
            
        }
        return resultDict
    }
    
    private class func insert(from json: Json, in context: NSManagedObjectContext) {
        let illness = context.insert(entityClass: Illness.self)
        illness?.update(from: json, in: context)
    }
    
    private func update(from json: Json, in context: NSManagedObjectContext) {
        context.performAndWait {
            let illness = context.object(with: objectID) as! Illness
            illness.id = json[C.Keys.ID] as? Int64 ?? 0
            illness.name = json[C.Keys.NAME] as? String
        }
    }
}
