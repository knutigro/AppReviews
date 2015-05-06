//
//  COImportController.swift
//  AppstoreReviews
//
//  Created by Knut Inge Grosland on 2015-04-09.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import Foundation
import AppKit
import SwiftyJSON

class DatabaseHandler {
    let context : NSManagedObjectContext
    
    // MARK: - Init & teardown

    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Managing context

    func saveContext() {
        var error : NSError? = nil
        self.context.save(&error)
        if error != nil { println("error: " + error!.localizedDescription) }
    }
    
    // MARK: - Applications handling
    
    func saveApplication(application : JSON) {
        if application.isApplicationEntity, let apID = application.trackId {
            if let managedApplication = Application.getWithAppId(apID, context: self.context) {
                managedApplication.updatedAt = NSDate()
                managedApplication.updateWithJSON(application)
            } else {
                let managedApplication = Application.getOrCreateNew(apID, context: self.context)
                managedApplication.updateWithJSON(application)
            }
            self.saveContext()
        }
    }
    
    func removeApplication(application : Application) {
        if let managedApplication = Application.getWithAppId(application.trackId, context: self.context) {
            self.context.deleteObject(managedApplication)
            self.saveContext()
        }
    }
    
    
    // Should be called with speccific thread
    func allApplications() -> [Application]? {
        let fetchRequest = NSFetchRequest(entityName: kEntityNameApplication)
        var error : NSError?
        
        let result = context.executeFetchRequest(fetchRequest, error: &error)
        
        if error != nil {
            println(error)
        }
        
        return result as? [Application]
    }
}
