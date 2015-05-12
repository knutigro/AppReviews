//
//  COReviewController.swift
//  AppstoreReviews
//
//  Created by Knut Inge Grosland on 2015-04-08.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import Foundation
import AppKit

let kSQLiteFileName = "db.sqlite4"

final class ReviewManager {

    private var persistentStack : PersistentStack!
    private var applicationUpdater: ApplicationUpdater!
    private var notificationsHandler : NotificationsHandler!

    // MARK: - Init & teardown

    init() {
        self.persistentStack = PersistentStack(storeURL: storeURL(), modelURL: modelURL())
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

    class func appUpdater() -> ApplicationUpdater {
        return ReviewManager.defaultManager.applicationUpdater
    }

    class func managedObjectContext() -> NSManagedObjectContext {
        return ReviewManager.defaultManager.persistentStack.managedObjectContext
    }

    class func backgroundObjectContext() -> NSManagedObjectContext {
        var context =  ReviewManager.defaultManager.persistentStack.setupManagedObjectContextWithConcurrencyType(.PrivateQueueConcurrencyType)
        context.undoManager = nil
        context.mergePolicy = NSMergePolicy(mergeType: NSMergePolicyType.OverwriteMergePolicyType)
        return context
    }

    class func saveContext() {
        var error : NSError? = nil
        ReviewManager.defaultManager.persistentStack.managedObjectContext.save(&error)
        if error != nil {
            println("error saving: \(error?.localizedDescription)")
        }
    }
    
    func storeURL() -> NSURL {
        let appName = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as? String ?? "AppReviews"
        var error: NSError? = nil
        let applicationSupportDirectory = NSFileManager.defaultManager().URLForDirectory(.ApplicationSupportDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true, error: &error)
        let appdirectory = applicationSupportDirectory?.URLByAppendingPathComponent(appName, isDirectory: true)
        let url = appdirectory?.URLByAppendingPathComponent(kSQLiteFileName)
        if error != nil {
            println("error storeURL: \(error?.localizedDescription)")
        }

        return url!
    }
    
    func modelURL() -> NSURL {
        return NSBundle.mainBundle().URLForResource("AppstoreReviews", withExtension: "momd")!
    }
}
