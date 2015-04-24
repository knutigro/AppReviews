//
//  ReviewUpdater.swift
//  AppstoreReviews
//
//  Created by Knut Inge Grosland on 2015-04-18.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import AppKit
import SwiftyJSON

// Update interval in seconds
let UpdateInterval = 60.0 * 60  // Each Hour

protocol ApplicationHandlerDelegate {
    func applicationHandler(applicationHandler : ApplicationHandler, didUpdateApplications applications: [Application])
    func applicationHandler(applicationHandler : ApplicationHandler, didUpdateReviews reviews: [Review])
}

// MARK: - ApplicationMonitor

extension Application {
    var secondsSinceLastReviewFetch : Int {
        get {
            return Int(NSDate().timeIntervalSinceDate(self.reviewsUpdatedAt))
        }
    }
}


class ApplicationHandler {
    
    var timer: Timer?
    var applications = [Application]()
    var delegate: ApplicationHandlerDelegate?

    // MARK: - Init & teardown
    
    init() {
        
        self.updateApplications()

        let backgroundManagedObjectContext = ReviewManager.backgroundManagedObjectContext();

        let databaseMonitor = NSNotificationCenter.defaultCenter().addObserverForName(NSManagedObjectContextDidSaveNotification, object: nil, queue: nil) {  [weak self] notification in
            if notification.object as? NSManagedObjectContext == backgroundManagedObjectContext, let strongSelf = self {
                if let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as? NSSet {
                    for object in insertedObjects {
                        if let application = object as? Application {
                            strongSelf.updateApplications()
                            return
                        }
                    }
                }
                if let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] as? NSSet {
                    for object in deletedObjects {
                        if let application = object as? Application {
                            strongSelf.updateApplications()
                        }
                    }
                }
            }
        }

        self.timer = Timer.repeatEvery(UpdateInterval) { [weak self] inTimer in
            if let strongSelf = self {
//                strongSelf.updateReviewsForAllApplications()
                println("updateReviewsForAllApplications")
            }
        }
    }
    
    func updateReviewsForAllApplications() {
        for application in self.applications {
            if application.secondsSinceLastReviewFetch == 0 || application.secondsSinceLastReviewFetch > Int(UpdateInterval) {
                self.fetchReviewsFromItunes(application, storeId: nil)
            }
        }
    }
    
    func updateApplications(){
        if let dBApplications = ReviewManager.dbHandler().allApplications() {
            for dBApplication in dBApplications {
                
                if !contains(applications, dBApplication) {
                    applications.append(dBApplication)
                    self.fetchReviewsFromItunes(dBApplication, storeId: nil)
                }
            }
            
            var applicationsToRemove = [Application]()
            for application in self.applications {
                if !contains(dBApplications, application) {
                    applicationsToRemove.append(application)
                }
            }
            
            for applicationToRemove in applicationsToRemove {
                self.applications.removeObject(applicationToRemove)
            }
        }
        
        println("-------")
        for application in self.applications {
            println("application " + application.trackName)
        }
        println("-------")

        self.delegate?.applicationHandler(self, didUpdateApplications: self.applications)
    }
    
    // MARK: - Reviews handling
    
    func fetchReviewsFromItunes(application: Application, storeId: String?) {
        println("import reviews for \(application.trackName) store \(storeId)")

        var context = ReviewManager.dbHandler().context
        var managedApplication = Application.getOrCreateNew(application.trackId, context: context)
        managedApplication.reviewsUpdatedAt = NSDate()
        
        RequestHandler(apId: application.trackId, storeId: storeId).fetchReview() {  [weak self]
            (success: Bool, reviews: [JSON]?, error : NSError?)
            in
            
            let blockSuccess = success as Bool
            let blockError = error
            
            ReviewManager.dbHandler().context

            context.performBlock({ () -> Void in
                
                if let blockReviews = reviews {
                    
                    for var index = 0; index < blockReviews.count; index++ {
                        let entry = blockReviews[index]
                        
                        if entry.isReviewEntity, let apID = entry.reviewApID {
                            var review = Review.getOrCreateNew(apID, context: context)
                            review.updateWithJSON(entry)
                            review.country = storeId ?? ""
                            review.updatedAt = NSDate()
                            var reviews = managedApplication.mutableSetValueForKey("reviews")
                            reviews.addObject(review)
                            review.application = managedApplication
                        }
                    }
                    ReviewManager.dbHandler().saveContext()
                }
            })
        }
    }

}
