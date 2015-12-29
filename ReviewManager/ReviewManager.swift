//
//  COReviewController.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-04-08.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import Foundation
import AppKit
import Ensembles

let kSQLiteFileName = "db.sqlite"

final class ReviewManager: NSObject {

    private var persistentStack: PersistentStack!
    private var applicationUpdater: ApplicationUpdater!
    private var notificationsHandler: NotificationsHandler!
    private var persistentStoreEnsemble: CDEPersistentStoreEnsemble!
    private var cloudFileSystem: CDEICloudFileSystem!

    // MARK: - Init & teardown

    override init() {
        super.init()
        persistentStack = PersistentStack(storeURL: storeURL(), modelURL: modelURL())
        notificationsHandler = NotificationsHandler()
        
        cloudFileSystem = CDEICloudFileSystem(ubiquityContainerIdentifier: "iCloud.com.cocmoc.appreviews")
        persistentStoreEnsemble = CDEPersistentStoreEnsemble(ensembleIdentifier: "MainStore", persistentStoreURL: self.storeURL(), managedObjectModelURL: modelURL(), cloudFileSystem: cloudFileSystem)
        persistentStoreEnsemble.delegate = self
    }
    
    class var defaultManager: ReviewManager {
        struct Singleton {
            static let instance = ReviewManager()
        }
        return Singleton.instance
    }
    
    class func start() -> ReviewManager {
        
        let manager = ReviewManager.defaultManager
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
        let context =  ReviewManager.defaultManager.persistentStack.setupManagedObjectContextWithConcurrencyType(.PrivateQueueConcurrencyType)
        context.undoManager = nil
        context.mergePolicy = NSMergePolicy(mergeType: NSMergePolicyType.OverwriteMergePolicyType)
        return context
    }

    class func saveContext() {
        do {
            try ReviewManager.defaultManager.persistentStack.managedObjectContext.save()
        } catch let error as NSError {
            print(error)
        }
    }
    
    func storeURL() -> NSURL {
        var error: NSError?
        var message = "There was an error creating or loading the application's saved data."
        
        // Make sure the application files directory is there
        var propertiesOpt: [NSObject: AnyObject]?
        do {
            propertiesOpt = try self.applicationDocumentsDirectory.resourceValuesForKeys([NSURLIsDirectoryKey])
        } catch let error1 as NSError {
            error = error1
        }
        if let properties = propertiesOpt {
            if !properties[NSURLIsDirectoryKey]!.boolValue {
                message = "Expected a folder to store application data, found a file \(self.applicationDocumentsDirectory.path)."
            }
        } else if error?.code == NSFileReadNoSuchFileError {
            error = nil
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(self.applicationDocumentsDirectory.path!, withIntermediateDirectories: true, attributes: nil)
            } catch let error1 as NSError {
                error = error1
            }
        }
        if (error != nil) { print(message + " Error: \(error)") }
        
        return self.applicationDocumentsDirectory.URLByAppendingPathComponent(kSQLiteFileName)
    }
    
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
        let appSupportURL = urls[urls.count - 1] 
        
        let appName = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as? String ?? "App Reviews"
        return appSupportURL.URLByAppendingPathComponent(appName)
        }()

    func modelURL() -> NSURL {
        return NSBundle.mainBundle().URLForResource("AppReviews", withExtension: "momd")!
    }
}

// MARK: CDEPersistentStoreEnsembleDelegate

extension ReviewManager: CDEPersistentStoreEnsembleDelegate {
    
    func persistentStoreEnsembleWillImportStore(ensemble: CDEPersistentStoreEnsemble!) {
        print("persistentStoreEnsembleWillImportStore")
    }
    
    func persistentStoreEnsemble(ensemble: CDEPersistentStoreEnsemble!, didSaveMergeChangesWithNotification notification: NSNotification!) {
        print("persistentStoreEnsemble didSaveMergeChangesWithNotification")
        ReviewManager.managedObjectContext().mergeChangesFromContextDidSaveNotification(notification)
    }
    
//    func persistentStoreEnsemble(ensemble: CDEPersistentStoreEnsemble!, globalIdentifiersForManagedObjects objects: [AnyObject]!) -> [AnyObject]! {
//        if let applications = objects as? [Application] {
//            return [applications]
//        } else {
//            
//        }
//        //    return [objects valueForKeyPath:@"uniqueIdentifier"];
//    }
}