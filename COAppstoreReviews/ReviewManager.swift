//
//  COReviewController.swift
//  AppstoreReviews
//
//  Created by Knut Inge Grosland on 2015-04-08.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import Foundation
import AppKit

final class ReviewManager {

    private var persistentStack : PersistentStack!
    private var coreDataHandler : DatabaseHandler!
    var applicationUpdater: ApplicationUpdater!
    var notificationsHandler : NotificationsHandler!

    // MARK: - Init & teardown

    init() {
        self.persistentStack = PersistentStack(storeURL: storeURL(), modelURL: modelURL())
        self.coreDataHandler = DatabaseHandler(context: self.persistentStack.backgroundManagedObjectContext)
        self.notificationsHandler = NotificationsHandler()
    }
    
    class var defaultManager: ReviewManager {
        struct Singleton {
            static let instance = ReviewManager()
        }
        return Singleton.instance
    }
    
    class func start() -> ReviewManager {
        
        var manager = ReviewManager.defaultManager
        manager.applicationUpdater = ApplicationUpdater()

        return manager
    }
    
    // MARK: - Core Data stack

    class func dbHandler() -> DatabaseHandler {
        return ReviewManager.defaultManager.coreDataHandler
    }

    class func appUpdater() -> ApplicationUpdater {
        return ReviewManager.defaultManager.applicationUpdater
    }

    class func managedObjectContext() -> NSManagedObjectContext {
        return ReviewManager.defaultManager.persistentStack.managedObjectContext
    }

    class func backgroundManagedObjectContext() -> NSManagedObjectContext {
        return ReviewManager.defaultManager.persistentStack.backgroundManagedObjectContext
    }

    class func saveContext() {
        var error : NSError? = nil
        ReviewManager.defaultManager.persistentStack.managedObjectContext.save(&error)
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
}
