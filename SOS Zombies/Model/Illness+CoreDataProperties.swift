//
//  Illness+CoreDataProperties.swift
//  SOS Zombies
//
//  Created by Achref Marzouki on 21/4/21.
//
//

import Foundation
import CoreData


extension Illness {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Illness> {
        return NSFetchRequest<Illness>(entityName: "Illness")
    }

    @NSManaged public var id: Int64
    @NSManaged public var name: String?

}
