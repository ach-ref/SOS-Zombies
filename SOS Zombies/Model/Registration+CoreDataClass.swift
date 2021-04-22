//
//  Registration+CoreDataClass.swift
//  SOS Zombies
//
//  Created by Achref Marzouki on 22/4/21.
//
//

import Foundation
import CoreData

@objc(Registration)
public class Registration: NSManagedObject {

    // MARK: - Private
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()
    
    lazy var dateComponentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.zeroFormattingBehavior = .dropAll
        return formatter
    }()
    
    // MARK: - Public
    
    class func all(in context: NSManagedObjectContext) -> [Registration] {
        var registrations: [Registration] = []
        context.performAndWait {
            let request: NSFetchRequest = fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: #keyPath(lastUpdated), ascending: false)]
            if let result = try? context.fetch(request) {
                registrations = result
            }
        }
        return registrations
    }
    
    // MARK: - Calculated properties
    
    var registrationDate: String {
        var result = ""
        managedObjectContext?.performAndWait {
            guard let aDate = lastUpdated else { return }
            let timeInterval = Date().timeIntervalSince(aDate)
            if timeInterval > 60 * 60 * 24 {
                result = dateFormatter.string(from: aDate)
            } else {
                let formatted = dateComponentsFormatter.string(from: timeInterval) ?? "--"
                result = String(format: NSLocalizedString("general.pastTime", comment: ""), formatted)
            }
        }
        return result
    }
}
