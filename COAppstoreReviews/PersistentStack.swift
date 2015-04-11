//
//  PersistentStack.swift
//  AppstoreReviews
//
//  Created by Knut Inge Grosland on 2015-04-09.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import Foundation
import AppKit

class PersistentStack {
    
    var managedObjectContext : NSManagedObjectContext!
    var backgroundManagedObjectContext : NSManagedObjectContext!
    var modelURL : NSURL
    var storeURL : NSURL
    
    init(storeURL: NSURL, modelURL : NSURL) {
        self.modelURL = modelURL
        self.storeURL = storeURL
        self.setupManagedObjectContexts()
    }

    func setupManagedObjectContexts() {
        
        self.managedObjectContext = self.setupManagedObjectContextWithConcurrencyType(.MainQueueConcurrencyType)
        self.managedObjectContext.undoManager = NSUndoManager()

        self.backgroundManagedObjectContext = self.setupManagedObjectContextWithConcurrencyType(.PrivateQueueConcurrencyType)
        self.backgroundManagedObjectContext.undoManager = nil
        
        let newToken = NSNotificationCenter.defaultCenter().addObserverForName(NSManagedObjectContextDidSaveNotification, object: nil, queue: nil) { note in
            let moc = self.managedObjectContext;
            if note.object as? NSManagedObjectContext != moc {
                moc.performBlock({ () -> Void in
                    moc .mergeChangesFromContextDidSaveNotification(note)
                })
            }
        }
    }
    
    func setupManagedObjectContextWithConcurrencyType(concurrencyType: NSManagedObjectContextConcurrencyType) -> NSManagedObjectContext {
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: concurrencyType)
        
        if let managedObjectModel = self.managedObjectModel() {
            managedObjectContext.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
            var error : NSError?
            managedObjectContext.persistentStoreCoordinator?.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: self.storeURL, options: nil, error: &error)
            if error != nil {
                println(error)
                println(self.storeURL.path)
            }
        }
        
        return managedObjectContext;
    }
    
    func managedObjectModel() -> NSManagedObjectModel? {
        return NSManagedObjectModel(contentsOfURL: self.modelURL)
    }
    
}