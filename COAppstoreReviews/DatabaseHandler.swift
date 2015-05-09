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
    
    typealias CompletionBlock = () -> ()
    
    // MARK: - Applications handling

    class func saveApplication(applicationJSON : JSON) {
        DatabaseHandler.saveDataInContext({ (context) -> Void in
            
            if applicationJSON.isApplicationEntity, let apID = applicationJSON.trackId {
                if let application = Application.getWithAppId(apID, context: context) {
                    application.updatedAt = NSDate()
                    application.updateWithJSON(applicationJSON)
                } else {
                    let application = Application.new(apID, context: context)
                    application.updateWithJSON(applicationJSON)
                }
            }
        })
    }
    
    class func removeApplication(objectId : NSManagedObjectID) {
        DatabaseHandler.saveDataInContext({ (context) -> Void in
            var error : NSError?
            if let application = context.existingObjectWithID(objectId, error: &error) {
                context.deleteObject(application)
            }
        })
    }
    
    class func resetNewReviewsCountForApplication(objectId : NSManagedObjectID) {
        DatabaseHandler.saveDataInContext({ (context) -> Void in
            var error : NSError?
            if let application = context.existingObjectWithID(objectId, error: &error) as? Application {
                application.settings.resetNewReviews()
            }
        })
    }

    class func allApplications(context: NSManagedObjectContext) -> [Application]? {
        
        let fetchRequest = NSFetchRequest(entityName: kEntityNameApplication)
        var error : NSError?
        let result = context.executeFetchRequest(fetchRequest, error: &error)
        if error != nil {
            println(error)
        }
        
        return result as? [Application]
    }
    
    // MARK: - DB Handling

    class func saveDataInContext(saveBlock: (context: NSManagedObjectContext) -> Void)  {
        DatabaseHandler.saveDataInContext(saveBlock, completion: nil)
    }

    class func saveDataInContext(saveBlock: (context: NSManagedObjectContext) -> Void, completion: CompletionBlock?)  {

        var context = ReviewManager.defaultManager.persistentStack.setupManagedObjectContextWithConcurrencyType(.PrivateQueueConcurrencyType)
        context.undoManager = nil
        
        context.performBlock { () -> Void in
            saveBlock(context: context)
            
            if context.hasChanges {
                var error : NSError? = nil
                context.save(&error)
                if error != nil { println("error: " + error!.localizedDescription) }
            }

            
            if let completion = completion {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion()
                })
            }
        }
    }
    



}
