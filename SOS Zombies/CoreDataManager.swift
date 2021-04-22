//
//  CoreDataManager.swift
//  SOS Zombies
//
//  Created by Achref Marzouki on 21/4/21.
//

import CoreData

final class CoreDataManager: NSObject {
    
    // MARK: - Private
    
    private let modelName = "SOS_Zombies"
    
    private var storeUrl: URL {
        do {
            return try FileManager
                .default
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("\(modelName).sqlite")
        } catch {
            fatalError("Unable to locate the \"Appliction Support\" directory!")
        }
    }
    
    // MARK: - Shared instance
    
    static let shared: CoreDataManager = CoreDataManager()
    
    // MARK: - Core Data Stack
    
    var managedContext: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
    
    var managedObjectModel: NSManagedObjectModel {
        return self.persistentContainer.managedObjectModel
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
        let url = container.persistentStoreDescriptions.last?.url ?? storeUrl
        let description = NSPersistentStoreDescription(url: url)
        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        #if DEBUG
        print("+++++ CoreData Store located at", url.path)
        #endif
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
