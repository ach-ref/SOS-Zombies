//
//  QueueEntry+CoreDataClass.swift
//  SOS Zombies
//
//  Created by Achref Marzouki on 21/4/21.
//
//

import Foundation
import CoreData

@objc(QueueEntry)
public class QueueEntry: NSManagedObject {

    // MARK: - Public
    
    class func insert(fromJson jsonList: [Json], in conext: NSManagedObjectContext) -> [QueueEntry] {
        var list: [QueueEntry] = []
        jsonList.forEach { list.append(insert(from: $0, in: conext)) }
        return list
    }
    
    // MARK: - Helpers
    
    private class func insert(from json: Json, in context: NSManagedObjectContext) -> QueueEntry {
        var entry: QueueEntry!
        context.performAndWait {
            if let queueEntry = context.insert(entityClass: QueueEntry.self) {
                entry = queueEntry
                entry.painLevel = json[C.Keys.PAIN_LEVEL] as? Int16 ?? 0
                entry.patientCount = json[C.Keys.PATIENT_COUNT] as? Int16 ?? 0
                entry.processTime = json[C.Keys.PROCESSING_TIME] as? Int16 ?? 0
            } else {
                fatalError("Unable to insert a new \"QueueEntry\" record!")
            }
        }
        
        return entry
    }
}
