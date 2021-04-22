//
//  Hospital+CoreDataClass.swift
//  SOS Zombies
//
//  Created by Achref Marzouki on 21/4/21.
//
//

import Foundation
import CoreData

@objc(Hospital)
public class Hospital: NSManagedObject {

    // MARK: - Public
    
    class func insertOrUpdate(fromJson jsonList: [Json], in conext: NSManagedObjectContext) {
        let ids = jsonList.compactMap { $0[C.Keys.ID] as? Int64 }
        let exisitingRecords = existingRecords(for: ids, in: conext)
        jsonList.forEach {
            let id = $0[C.Keys.ID] as? Int64 ?? 0
            if let existing = exisitingRecords[id] {
                existing.update(from: $0, in: conext)
            } else {
                insert(from: $0, in: conext)
            }
        }
    }
    
    class func all(in context: NSManagedObjectContext) -> [Hospital] {
        var hospitals: [Hospital] = []
        context.performAndWait {
            let request: NSFetchRequest = fetchRequest()
            if let result = try? context.fetch(request) {
                hospitals = result
            }
        }
        return hospitals
    }
    
    func hospitalInfo(painLevel: Int16, userLocation: CLLocation?) -> (time: Int16, distance: CLLocationDistance) {
        var time: Int16 = 0, distance: Double = -1
        managedObjectContext?.performAndWait {
            if let entry = (queue?.allObjects as? [QueueEntry])?.filter({ $0.painLevel == painLevel }).first {
                time = entry.patientCount * entry.processTime
            }
            guard let userLoc = userLocation else { return }
            let loc = CLLocation(latitude: latitude, longitude: longitude)
            distance = userLoc.distance(from: loc) / 1000
        }
        return (time, distance)
    }
    
    func processingTime(forPainLevel painLevel: Int16) -> Int16 {
        var time: Int16 = 0
        managedObjectContext?.performAndWait {
            if let entry = (queue?.allObjects as? [QueueEntry])?.filter({ $0.painLevel == painLevel }).first {
                time = entry.patientCount * entry.processTime
            }
        }
        return time
    }
    
    func distanceFrom(userLocation: CLLocation?) -> CLLocationDistance {
        var distance: Double = -1
        guard let userLoc = userLocation else { return distance }
        managedObjectContext?.performAndWait {
            let loc = CLLocation(latitude: latitude, longitude: longitude)
            distance = userLoc.distance(from: loc)
        }
        return distance
    }
    
    // MARK: - Helpers
    
    private class func existingRecords(for ids: [Int64], in context: NSManagedObjectContext) -> [Int64 : Hospital] {
        var resultDict: [Int64 : Hospital] = [:]
        context.performAndWait {
            let request: NSFetchRequest = fetchRequest()
            request.predicate = NSPredicate(format: "%K IN %@", #keyPath(id), ids)
            if let result = try? context.fetch(request) {
                resultDict = result.reduce(into: [Int64 : Hospital]()) { $0[$1.id] = $1 }
            }
            
        }
        return resultDict
    }
    
    private class func insert(from json: Json, in context: NSManagedObjectContext) {
        let hospital = context.insert(entityClass: Hospital.self)
        hospital?.update(from: json, in: context)
    }
    
    private func update(from json: Json, in context: NSManagedObjectContext) {
        context.performAndWait {
            let hospital = context.object(with: objectID) as! Hospital
            hospital.id = json[C.Keys.ID] as? Int64 ?? 0
            hospital.name = json[C.Keys.NAME] as? String
            // waiting list
            if let jsonQueue = json[C.Keys.WAITING_LIST] as? [Json] {
                if let queue = hospital.queue?.allObjects as? [QueueEntry] { queue.forEach { context.delete($0) } }
                hospital.queue = NSSet(array: QueueEntry.insert(fromJson: jsonQueue, in: context))
            }
            // location
            if let jsonLocation = json[C.Keys.LOCATION] as? Json {
                hospital.latitude = jsonLocation[C.Keys.LAT] as? Double ?? 0
                hospital.longitude = jsonLocation[C.Keys.LNG] as? Double ?? 0
            }
        }
    }
}
