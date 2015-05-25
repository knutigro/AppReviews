//
//  COReviewController.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-04-08.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import Foundation
import AppKit

let kSQLiteFileName = "db.sqlite"

final class ReviewManager {

    private var persistentStack: PersistentStack!
    private var applicationUpdater: ApplicationUpdater!
    private var notificationsHandler: NotificationsHandler!

    // MARK: - Init & teardown

    init() {
        persistentStack = PersistentStack(storeURL: storeURL(), modelURL: modelURL())
        notificationsHandler = NotificationsHandler()
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
        var error: NSError? = nil
        ReviewManager.defaultManager.persistentStack.managedObjectContext.save(&error)
        if error != nil {
            println("error saving: \(error?.localizedDescription)")
        }
    }
    
    func storeURL() -> NSURL {
        let appName = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as? String ?? "App Reviews"
        var error: NSError? = nil
        // ApplicationSupportDirectory
        
        let applicationSupportDirectory = NSFileManager.defaultManager().URLForDirectory(.DesktopDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true, error: &error)
        let appDirectory = applicationSupportDirectory?.URLByAppendingPathComponent(appName, isDirectory: true)
        
        let success = NSFileManager.defaultManager().createDirectoryAtPath(appDirectory!.URLString, withIntermediateDirectories: true, attributes: nil, error: &error)
        
        if error != nil {
            println("createDirectoryAtPath: \(error?.localizedDescription)")
        }

        let url = appDirectory?.URLByAppendingPathComponent(kSQLiteFileName)
        
        if error != nil {
            println("error storeURL: \(error?.localizedDescription)")
        }
        
        return url!
    }
    
    func modelURL() -> NSURL {
        return NSBundle.mainBundle().URLForResource("AppReviews", withExtension: "momd")!
    }
}
