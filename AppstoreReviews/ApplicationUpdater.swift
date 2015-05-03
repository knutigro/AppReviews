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
        
        let backgroundManagedObjectContext = ReviewManager.backgroundManagedObjectContext();

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
    }
    
    private func updateReviewsForAllApplications() {
        for application in self.applications {
            if application.settings.shouldUpdateReviews {
                self.fetchReviews(application, storeId: nil)
            }
        }
    }
    
    private func updateMonitoredApplications(){
        if let dBApplications = ReviewManager.dbHandler().allApplications() {
            for dBApplication in dBApplications {
                
                if !contains(self.applications, dBApplication) {
                    println("New application" + dBApplication.trackName)
                    applications.append(dBApplication)
                    self.fetchReviews(dBApplication, storeId: nil)
                }
            }
            
            var applicationsToRemove = [Application]()
            for application in self.applications {
                if !contains(dBApplications, application) {
                    applicationsToRemove.append(application)
                }
            }
            
            for applicationToRemove in applicationsToRemove {
                println("removing app")
                self.applications.removeObject(applicationToRemove)
            }
        }
    }
    
    // MARK: - Reviews handling
    
    func fetchReviews(application: Application, storeId: String?) {
        println("import reviews for \(application.trackName) store \(storeId)")

        var context = ReviewManager.dbHandler().context
        var managedApplication = Application.getOrCreateNew(application.trackId, context: context)
        
        ItunesService(apId: application.trackId, storeId: storeId).fetchReview() {  [weak self]
            (success: Bool, reviews: [JSON]?, error : NSError?) in
            
            let blockSuccess = success as Bool
            let blockError = error
            
            ReviewManager.dbHandler().context

            context.performBlock({ () -> Void in
                
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
                                managedApplication.settings.increaseNewReviews()
                            }
                            
                            review.updateWithJSON(entry)
                            review.country = storeId ?? ""
                            review.updatedAt = NSDate()
                            var reviews = managedApplication.mutableSetValueForKey("reviews")
                            reviews.addObject(review)
                            review.application = managedApplication
                            updatedReviews.append(review)
                        }
                    }
                    managedApplication.settings.updatedAt = NSDate()
                    managedApplication.settings.reviewsUpdatedAt = NSDate()
                    managedApplication.settings.nextUpdateAt = NSDate().dateByAddingTimeInterval(kDefaultReviewUpdateInterval)
                    
                    println("nextUpdateAt: \(managedApplication.settings.nextUpdateAt)" )

                    ReviewManager.dbHandler().saveContext()
                }
            })
        }
    }
    
    func resetNewReviews(application: Application) {
        if let managedApplication = Application.getWithAppId(application.trackId, context: ReviewManager.dbHandler().context){
            managedApplication.settings.resetNewReviews()
            ReviewManager.dbHandler().saveContext()
        }
    }
}
