//
//  NSManagedComtext+AddOn.swift
//  SOS Zombies
//
//  Created by Achref Marzouki on 21/4/21.
//

import CoreData

extension NSManagedObjectContext {
    
    /// Insert a new managed object according to the specified entity class type.
    ///
    /// - Parameter entityClass: Class of the managed object to insert
    /// - Returns: Optional managed object
    func insert<T: NSManagedObject>(entityClass: T.Type) -> T? {
        var newEntity: T?
        performAndWait {
            let entityDescription = NSEntityDescription.entity(forEntityName: String(describing: entityClass), in: self)
            if let _ = entityDescription {
                newEntity = NSManagedObject(entity: entityDescription!, insertInto: self) as? T
            }
        }
        
        return newEntity
    }
    
    // MARK: - Data operations
    
    /// Delete all records of the entity named entityName.
    ///
    /// - Parameter entityName: The entity name
    /// - Returns: An id's array of all deleted objects
    @discardableResult func truncateDataForEntityName(_ entityName: String) -> [NSManagedObjectID] {
        var ids: [NSManagedObjectID] = []
        performAndWait {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            deleteRequest.resultType = .resultTypeObjectIDs
            
            if let result = try? execute(deleteRequest) as? NSBatchDeleteResult {
                ids = result.result as! [NSManagedObjectID]
                let formattedEntityName = entityName.appending(" ").padding(toLength: 35, withPad: "-", startingAt: 0)
                print("\(formattedEntityName) Truncated")
            }
        }
        
        return ids
    }
    
    /// Delete all records of the given entity.
    ///
    /// - Parameter entityClass: entity class
    func truncateData<T: NSManagedObject>(for entityClass: T.Type) {
        truncateDataForEntityName(String(describing: entityClass))
    }
    
    // MARK: - Saving context
    
    /// Save context if it has changes.
    /// Can trigger a fatal error in case of catching an exception when saving.
    func saveContext() {
        
        performAndWait {
            
            // try to save current context
            if hasChanges {
                do {
                    try self.save()
                }
                catch {
                    let nsError = error as NSError
                    fatalError("Save context failure. Unresolved error \(nsError)\n\(nsError.userInfo)")
                }
            }
        }
    }
}
