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

class DataBaseController {
    let context : NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func saveContext() {
        var error : NSError? = nil
        self.context.save(&error)
        if error != nil { println("error: " + error!.localizedDescription) }
    }
    
    func updateReviews(application: Application, storeId: String?) {
        // [unowned self]
        println("import reviews for \(application.trackName) store \(storeId)")
        
        var managedApplication = Application.findOrCreateNewApplication(application.trackId, context: self.context)
        
        let reviewFetcher = ReviewFetcher(apId: application.trackId, storeId: storeId)
        
        reviewFetcher.fetchReview() {
            (success: Bool, reviews: [JSON]?, error : NSError?)
             in

            let blockSuccess = success as Bool
            let blockError = error

            self.context.performBlock({ () -> Void in
                
                if let blockReviews = reviews {
                    
                    for var index = 0; index < blockReviews.count; index++ {
                        let entry = blockReviews[index]
                        
                        if entry.isReviewEntity, let apID = entry.reviewApID {
                            var review = Review.findOrCreateNewReview(apID, context: self.context)
                            review.updateWithJSON(entry)
                            review.country = storeId ?? ""
                            review.updatedAt = NSDate()
                            var reviews = managedApplication.mutableSetValueForKey("reviews")
                            reviews.addObject(review)
                            review.application = managedApplication
                        }
                    }
                    self.saveContext()
                }
            })
        }
    }
    
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
}
