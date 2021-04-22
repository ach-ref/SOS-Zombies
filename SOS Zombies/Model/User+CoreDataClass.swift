//
//  User+CoreDataClass.swift
//  SOS Zombies
//
//  Created by Achref Marzouki on 22/4/21.
//
//

import Foundation
import CoreData

@objc(User)
public class User: NSManagedObject {

    // MARK: - Public
    
    class func getUserNamed(_ userName: String, in context: NSManagedObjectContext) -> User {
        var user: User!
        context.performAndWait {
            let request: NSFetchRequest = fetchRequest()
            request.predicate = NSPredicate(format: "%K == %@", #keyPath(name), userName)
            request.fetchLimit = 1
            if let result = try? context.fetch(request) {
                if result.first == nil {
                    guard let newUSer = context.insert(entityClass: User.self) else {
                        fatalError("Unable to insert a new User record!")
                    }
                    newUSer.name = userName
                    user = newUSer
                } else {
                    user = result.first
                }
            }
        }
        
        return user
    }
    
    func registration(forIllness illness: Illness, in context: NSManagedObjectContext) -> (registration: Registration, isNew: Bool) {
        var registration: Registration!, isNew = false
        context.performAndWait {
            if let existingReg = (registrations?.array as? [Registration])?.filter({ $0.illness?.id == illness.id }).first {
                registration = existingReg
            } else {
                guard let newRegistration = context.insert(entityClass: Registration.self) else {
                    fatalError("Unable to insert a new Registration record!")
                }
                isNew = true
                registration = newRegistration
                registration.illness = context.object(with: illness.objectID) as? Illness
                addToRegistrations(registration)
            }
        }
        return (registration, isNew)
    }
}
