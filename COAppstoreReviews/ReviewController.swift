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

class ReviewController {
    let context : NSManagedObjectContext
    
    // MARK: Init & teardown

    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: Managing context

    private func saveContext() {
        var error : NSError? = nil
        self.context.save(&error)
        if error != nil { println("error: " + error!.localizedDescription) }
    }
    
    // MARK: Reviews handling
    
    func updateReviews(application: Application, storeId: String?) {
        println("import reviews for \(application.trackName) store \(storeId)")
        
        var managedApplication = Application.findOrCreateNewApplication(application.trackId, context: self.context)
        
        let reviewFetcher = ReviewFetcher(apId: application.trackId, storeId: storeId)
        
        reviewFetcher.fetchReview() {  [weak self]
            (success: Bool, reviews: [JSON]?, error : NSError?)
             in

            let blockSuccess = success as Bool
            let blockError = error

            if let strongSelf = self {
                strongSelf.context.performBlock({ () -> Void in
                    
                    if let blockReviews = reviews {
                        
                        for var index = 0; index < blockReviews.count; index++ {
                            let entry = blockReviews[index]
                            
                            if entry.isReviewEntity, let apID = entry.reviewApID {
                                var review = Review.findOrCreateNewReview(apID, context: strongSelf.context)
                                review.updateWithJSON(entry)
                                review.country = storeId ?? ""
                                review.updatedAt = NSDate()
                                var reviews = managedApplication.mutableSetValueForKey("reviews")
                                reviews.addObject(review)
                                review.application = managedApplication
                            }
                        }
                        strongSelf.saveContext()
                    }
                })
            }
        }
    }
    
    // MARK: Applications handling
    
    func updateApplication(application : JSON) {
        if application.isApplicationEntity, let apID = application.trackId {
            var managedApplication = Application.findOrCreateNewApplication(apID, context: self.context)
            managedApplication.updatedAt = NSDate()
            managedApplication.updateWithJSON(application)
            self.saveContext()
        }
    }
    
    func removeApplication(application : Application) {
        var managedApplication = Application.findOrCreateNewApplication(application.trackId, context: self.context)
        self.context.deleteObject(managedApplication)
        self.saveContext()
    }
    
    func fetchAllApplications() -> [Application]? {
        let fetchRequest = NSFetchRequest(entityName: kEntityNameApplication)
        var error : NSError?
        
        let result = context.executeFetchRequest(fetchRequest, error: &error)
        
        if error != nil {
            println(error)
        }
        
        return result as? [Application]
    }
}
