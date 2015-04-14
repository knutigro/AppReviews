//
//  COReviewController.swift
//  AppstoreReviews
//
//  Created by Knut Inge Grosland on 2015-04-08.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import Foundation

class ReviewController {
    
    var persistentStack : PersistentStack!
    var dataBaseController : DataBaseController!
    
    
    init() {
        self.persistentStack = PersistentStack(storeURL: storeURL(), modelURL: modelURL())
        self.dataBaseController = DataBaseController(context: self.persistentStack.backgroundManagedObjectContext)
    }
    
    class var sharedInstance: ReviewController {
        struct Singleton {
            static let instance = ReviewController()
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
