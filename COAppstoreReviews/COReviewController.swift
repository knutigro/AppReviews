//
//  COReviewController.swift
//  AppstoreReviews
//
//  Created by Knut Inge Grosland on 2015-04-08.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import Foundation

class COReviewController {
    
    var persistentStack : PersistentStack!
    var importController : COImportController!
    
    
    init() {
        persistentStack = PersistentStack(storeURL: storeURL(), modelURL: modelURL())
        importController = COImportController(context: persistentStack.backgroundManagedObjectContext)
    }
    
    class var sharedInstance: COReviewController {
        struct Singleton {
            static let instance = COReviewController()
        }
        return Singleton.instance
    }
    
    // MARK: - Core Data stack
    
    func saveContext() {
        var error : NSError? = nil
        self.persistentStack.managedObjectContext.save(&error)
        if error != nil {
            println("error saving: \(error?.localizedDescription)")
        }
    }
    
    func storeURL() -> NSURL {
        var error: NSError? = nil
        let documentsDirectory = NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true, error: &error)
        let url = documentsDirectory?.URLByAppendingPathComponent("db.sqlite")
        if error != nil {
            println("error storeURL: \(error?.localizedDescription)")
        }

        return url!
    }
    
    func modelURL() -> NSURL {
        return NSBundle.mainBundle().URLForResource("AppstoreReviews", withExtension: "momd")!
    }
    
    // MARK: - Fetching Reviews

}
