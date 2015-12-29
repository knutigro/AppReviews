//
//  PersistentStack.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-04-09.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import Foundation
import AppKit

let kDidAddReviewsNotification                = "kDidAddReviewsNotification"
let kDidUpdateApplicationNotification         = "kDidUpdateApplicationNotification"
let kDidUpdateApplicationSettingsNotification = "kDidUpdateApplicationSettingsNotification"
let kDidUpdateReviewsNotification             = "kDidUpdateReviewsNotification"

class PersistentStack {
    
    var managedObjectContext: NSManagedObjectContext!
    var modelURL: NSURL
    var storeURL: NSURL
    
    init(storeURL: NSURL, modelURL: NSURL) {
        self.modelURL = modelURL
        self.storeURL = storeURL
        setupManagedObjectContexts()
    }

    func setupManagedObjectContexts() {
        
        managedObjectContext = setupManagedObjectContextWithConcurrencyType(.MainQueueConcurrencyType)
        managedObjectContext.undoManager = NSUndoManager()

        _ = NSNotificationCenter.defaultCenter().addObserverForName(NSManagedObjectContextDidSaveNotification, object: nil, queue: nil) { [weak self] notification in
                self?.managedObjectDidSave(notification)
        }
    }
    
    func managedObjectDidSave(notification: NSNotification) {
        let moc = managedObjectContext;
        if notification.object as? NSManagedObjectContext != moc {
            moc.performBlock({ [weak self] () -> Void in
                
                self?.mergeChangesFromSaveNotification(notification, intoContext: moc)
                
                var newReviews =  Set<NSManagedObjectID>()
                var updatedReviews = Set<NSManagedObjectID>()
                var updatedApplications = Set<NSManagedObjectID>()
                var updatedApplicationSettings = Set<NSManagedObjectID>()
                
                if let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as? NSSet {
                    for object in insertedObjects {
                        if let application = object as? Application {
                            updatedApplications.insert(application.objectID)
                        }
                        if let review = object as? Review {
                            newReviews.insert(review.objectID)
                            updatedReviews.insert(review.objectID)
                        }
                        if let application = object as? ApplicationSettings {
                            updatedApplicationSettings.insert(application.objectID)
                        }
                    }
                }
                if let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] as? NSSet {
                    for object in deletedObjects {
                        if let application = object as? Application {
                            updatedApplications.insert(application.objectID)
                        }
                        if let review = object as? Review {
                            updatedReviews.insert(review.objectID)
                        }
                        if let settings = object as? ApplicationSettings {
                            updatedApplicationSettings.insert(settings.objectID)
                        }
                    }
                }
                if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? NSSet {
                    for object in updatedObjects {
                        if let application = object as? Application {
                            updatedApplications.insert(application.objectID)
                        }
                        if let review = object as? Review {
                            updatedReviews.insert(review.objectID)
                        }
                        if let settings = object as? ApplicationSettings {
                            updatedApplicationSettings.insert(settings.objectID)
                        }
                    }
                }
                
                if !newReviews.isEmpty {
                    NSNotificationCenter.defaultCenter().postNotificationName(kDidAddReviewsNotification, object: newReviews)
                }
                
                if !updatedApplications.isEmpty {
                    NSNotificationCenter.defaultCenter().postNotificationName(kDidUpdateApplicationNotification, object: updatedApplications)
                }
                if !updatedReviews.isEmpty {
                    NSNotificationCenter.defaultCenter().postNotificationName(kDidUpdateReviewsNotification, object: newReviews)
                }
                if !updatedApplicationSettings.isEmpty {
                    NSNotificationCenter.defaultCenter().postNotificationName(kDidUpdateApplicationSettingsNotification, object: updatedApplicationSettings)
                }
            })
        }
    }
    
    func mergeChangesFromSaveNotification(notification: NSNotification, intoContext context: NSManagedObjectContext) {
        //    // NSManagedObjectContext's merge routine ignores updated objects which aren't
        //    // currently faulted in. To force it to notify interested clients that such
        //    // objects have been refreshed (e.g. NSFetchedResultsController) we need to
        //    // force them to be faulted in ahead of the merge
        
        if let updatedObjects = notification.userInfo?[NSInsertedObjectsKey] as? NSSet {
            for anyObject in updatedObjects {
                if let managedObject = anyObject as? NSManagedObject {
                    do {
                        try context.existingObjectWithID(managedObject.objectID)
                    } catch let error as NSError {
                        print(error)
                    } catch {
                        fatalError()
                    }
                }
            }
        }
        context.mergeChangesFromContextDidSaveNotification(notification)
    }
    
    func setupManagedObjectContextWithConcurrencyType(concurrencyType: NSManagedObjectContextConcurrencyType) -> NSManagedObjectContext {
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: concurrencyType)
        if let managedObjectModel = managedObjectModel() {
            managedObjectContext.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
            do {
                try managedObjectContext.persistentStoreCoordinator?.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
            } catch let error as NSError {
                print(storeURL.path)
                print(error)
            }
        }
        
        return managedObjectContext;
    }
    
    func managedObjectModel() -> NSManagedObjectModel? {
        return NSManagedObjectModel(contentsOfURL: modelURL)
    }
    
}