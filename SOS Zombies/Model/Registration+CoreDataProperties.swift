//
//  Registration+CoreDataProperties.swift
//  SOS Zombies
//
//  Created by Achref Marzouki on 22/4/21.
//
//

import Foundation
import CoreData


extension Registration {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Registration> {
        return NSFetchRequest<Registration>(entityName: "Registration")
    }

    @NSManaged public var painLevel: Int16
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var illness: Illness?
    @NSManaged public var user: User?

}
