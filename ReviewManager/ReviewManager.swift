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
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        
        // Make sure the application files directory is there
        let propertiesOpt = self.applicationDocumentsDirectory.resourceValuesForKeys([NSURLIsDirectoryKey], error: &error)
        if let properties = propertiesOpt {
            if !properties[NSURLIsDirectoryKey]!.boolValue {
                failureReason = "Expected a folder to store application data, found a file \(self.applicationDocumentsDirectory.path)."
            }
        } else if error!.code == NSFileReadNoSuchFileError {
            error = nil
            NSFileManager.defaultManager().createDirectoryAtPath(self.applicationDocumentsDirectory.path!, withIntermediateDirectories: true, attributes: nil, error: &error)
        }
        
        return self.applicationDocumentsDirectory.URLByAppendingPathComponent(kSQLiteFileName)
    }
    
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
        let appSupportURL = urls[urls.count - 1] as! NSURL
        
        let appName = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as? String ?? "App Reviews"
        return appSupportURL.URLByAppendingPathComponent(appName)
        }()

    func modelURL() -> NSURL {
        return NSBundle.mainBundle().URLForResource("AppReviews", withExtension: "momd")!
    }
}
