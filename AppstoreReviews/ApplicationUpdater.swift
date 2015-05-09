//
//  ReviewUpdater.swift
//  AppstoreReviews
//
//  Created by Knut Inge Grosland on 2015-04-18.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import AppKit
import SwiftyJSON

let kTimerInterval = 60.0 // 60.0 * 60  // Update interval in seconds ->  Each Hour
let kDefaultReviewUpdateInterval = 60.0 * 60  // Update interval in seconds ->  Each Hour

class ApplicationUpdater {
    
    var timer: Timer?
    var applications = [Application]()

    // MARK: - Init & teardown
    
    init() {
        
        let applicationMonitor = NSNotificationCenter.defaultCenter().addObserverForName(kDidUpdateApplicationNotification, object: nil, queue: nil) {  [weak self] notification in
            if let strongSelf = self {
                strongSelf.updateMonitoredApplications()
            }
        }

        let applicationSettingsMonitor = NSNotificationCenter.defaultCenter().addObserverForName(kDidUpdateApplicationSettingsNotification, object: nil, queue: nil) {  [weak self] notification in
            if let strongSelf = self {
                strongSelf.updateMonitoredApplications()
            }
        }

        let reviewMonitor = NSNotificationCenter.defaultCenter().addObserverForName(kDidUpdateReviewsNotification, object: nil, queue: nil) {  [weak self] notification in
            if let strongSelf = self {
                strongSelf.updateMonitoredApplications()
            }
        }

        self.timer = Timer.repeatEvery(kTimerInterval) { [weak self] inTimer in
            if let strongSelf = self {
                println("timer click \(NSDate())")
                strongSelf.updateReviewsForAllApplications()
            }
        }
        
        self.updateMonitoredApplications();
    }
    
    private func updateReviewsForAllApplications() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            for application in self.applications {
                if application.settings.shouldUpdateReviews {
                    self.fetchReviewsForApplication(application.objectID)
                }
            }
        })
    }
    
    private func updateMonitoredApplications(){
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            if let dBApplications = DatabaseHandler.allApplications(ReviewManager.managedObjectContext()) {
                for dBApplication in dBApplications {
                    if !contains(self.applications, dBApplication) {
                        self.applications.append(dBApplication)
                        self.fetchReviewsForApplication(dBApplication.objectID)
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
        })
        
    }
    
    // MARK: - Reviews handling
    
    func fetchReviewsForApplication(objectId: NSManagedObjectID) {
        
        var error : NSError?
        
        if let fetchApplication = ReviewManager.managedObjectContext().existingObjectWithID(objectId, error: &error) as? Application {
            
            if error != nil {
                println(error)
            }
            
            ItunesService(apId: fetchApplication.trackId, storeId: nil).fetchReview() {  [weak self]
                (success: Bool, reviews: [JSON]?, error : NSError?) in
                
                let blockSuccess = success as Bool
                let blockError = error
                
                DatabaseHandler.saveDataInContext({ (context) -> Void in
                    
                    var error : NSError?

                    if let application = context.existingObjectWithID(objectId, error: &error) as? Application {
                        
                        if error != nil {
                            println(error)
                        }

                        if let blockReviews = reviews {
                            
                            var updatedReviews = [Review]()
                            
                            for var index = 0; index < blockReviews.count; index++ {
                                let entry = blockReviews[index]
                                
                                if entry.isReviewEntity, let apID = entry.reviewApID {
                                    var review : Review!
                                    
                                    if let newReview = Review.get(apID, context: context) {
                                        // Review allready exist in database
                                        review = newReview
                                    } else {
                                        // create new review
                                        review = Review.new(apID, context: context)
                                        application.settings.increaseNewReviews()
                                    }
                                    
                                    review.updateWithJSON(entry)
                                    review.country = ""
                                    review.updatedAt = NSDate()
                                    var reviews = application.mutableSetValueForKey("reviews")
                                    reviews.addObject(review)
                                    review.application = application
                                    updatedReviews.append(review)
                                }
                            }
                            application.settings.updatedAt = NSDate()
                            application.settings.reviewsUpdatedAt = NSDate()
                            application.settings.nextUpdateAt = NSDate().dateByAddingTimeInterval(kDefaultReviewUpdateInterval)
                            println("import reviews for \(application.trackName)")
                        }
                    }
                })
            }
        }
    }
    
    func resetNewReviewsCountForApplication(objectId: NSManagedObjectID) {
        DatabaseHandler.resetNewReviewsCountForApplication(objectId)
    }
}
