//
//  User+CoreDataProperties.swift
//  SOS Zombies
//
//  Created by Achref Marzouki on 22/4/21.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var name: String?
    @NSManaged public var insuranceID: String?
    @NSManaged public var registrations: NSOrderedSet?

}

// MARK: Generated accessors for registrations
extension User {

    @objc(insertObject:inRegistrationsAtIndex:)
    @NSManaged public func insertIntoRegistrations(_ value: Registration, at idx: Int)

    @objc(removeObjectFromRegistrationsAtIndex:)
    @NSManaged public func removeFromRegistrations(at idx: Int)

    @objc(insertRegistrations:atIndexes:)
    @NSManaged public func insertIntoRegistrations(_ values: [Registration], at indexes: NSIndexSet)

    @objc(removeRegistrationsAtIndexes:)
    @NSManaged public func removeFromRegistrations(at indexes: NSIndexSet)

    @objc(replaceObjectInRegistrationsAtIndex:withObject:)
    @NSManaged public func replaceRegistrations(at idx: Int, with value: Registration)

    @objc(replaceRegistrationsAtIndexes:withRegistrations:)
    @NSManaged public func replaceRegistrations(at indexes: NSIndexSet, with values: [Registration])

    @objc(addRegistrationsObject:)
    @NSManaged public func addToRegistrations(_ value: Registration)

    @objc(removeRegistrationsObject:)
    @NSManaged public func removeFromRegistrations(_ value: Registration)

    @objc(addRegistrations:)
    @NSManaged public func addToRegistrations(_ values: NSOrderedSet)

    @objc(removeRegistrations:)
    @NSManaged public func removeFromRegistrations(_ values: NSOrderedSet)

}
