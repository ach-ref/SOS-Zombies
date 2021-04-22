//
//  CoreDataManagerTest.swift
//  SOS ZombiesTests
//
//  Created by Achref Marzouki on 22/4/21.
//

import CoreData

final class CoreDataManagerTest: NSObject {
    
    // MARK: - Private
    
    private let modelName = "SOS_Zombies"
    
    // MARK: - Shared instance
    
    static let shared = CoreDataManagerTest()
    
    // MARK: - Stack
    
    var managedContext: NSManagedObjectContext {
        return self.storeContainer.viewContext
    }
    
    var managedObjectModel: NSManagedObjectModel {
        return self.storeContainer.managedObjectModel
    }
    
    lazy var storeContainer: NSPersistentContainer = {
        // container
        let container = NSPersistentContainer(name: self.modelName)
        // container description - In memory type
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        // load stores
        container.loadPersistentStores { (storeDescrption, error) in
            if let error = error as NSError? {
                fatalError("Error while creating core data stack : \(error), \(error.userInfo)")
            }
        }
        
        return container
    }()
}
