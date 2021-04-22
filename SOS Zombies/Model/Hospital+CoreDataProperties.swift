//
//  Hospital+CoreDataProperties.swift
//  SOS Zombies
//
//  Created by Achref Marzouki on 22/4/21.
//
//

import Foundation
import CoreData


extension Hospital {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Hospital> {
        return NSFetchRequest<Hospital>(entityName: "Hospital")
    }

    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var longitude: Double
    @NSManaged public var latitude: Double
    @NSManaged public var queue: NSSet?

}

// MARK: Generated accessors for queue
extension Hospital {

    @objc(addQueueObject:)
    @NSManaged public func addToQueue(_ value: QueueEntry)

    @objc(removeQueueObject:)
    @NSManaged public func removeFromQueue(_ value: QueueEntry)

    @objc(addQueue:)
    @NSManaged public func addToQueue(_ values: NSSet)

    @objc(removeQueue:)
    @NSManaged public func removeFromQueue(_ values: NSSet)

}
