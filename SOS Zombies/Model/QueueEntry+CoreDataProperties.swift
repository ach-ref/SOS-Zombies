//
//  QueueEntry+CoreDataProperties.swift
//  SOS Zombies
//
//  Created by Achref Marzouki on 21/4/21.
//
//

import Foundation
import CoreData


extension QueueEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<QueueEntry> {
        return NSFetchRequest<QueueEntry>(entityName: "QueueEntry")
    }

    @NSManaged public var painLevel: Int16
    @NSManaged public var patientCount: Int16
    @NSManaged public var processTime: Int16
    @NSManaged public var hospital: Hospital?

}
