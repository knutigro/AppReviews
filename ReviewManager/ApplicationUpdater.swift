//
//  ReviewUpdater.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-04-18.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import AppKit
import SwiftyJSON

let kTimerInterval = 60.0 // 60.0 * 60  // Update interval in seconds ->  Each Hour
let kDefaultReviewUpdateInterval = 60.0 * 60  // Update interval in seconds ->  Each Hour

class ApplicationUpdater {
    
    private var timer: Timer?
    private var applications = [Application]()
    
    var numberOfMonitoredApplications: Int {
        return applications.count
    }

    // MARK: - Init & teardown
    
    init() {
        
        let applicationMonitor = NSNotificationCenter.defaultCenter().addObserverForName(kDidUpdateApplicationNotification, object: nil, queue: nil) {  [weak self] notification in
            self?.updateMonitoredApplications()
        }

        let applicationSettingsMonitor = NSNotificationCenter.defaultCenter().addObserverForName(kDidUpdateApplicationSettingsNotification, object: nil, queue: nil) {  [weak self] notification in
            self?.updateMonitoredApplications()
        }

        let reviewMonitor = NSNotificationCenter.defaultCenter().addObserverForName(kDidUpdateReviewsNotification, object: nil, queue: nil) {  [weak self] notification in
            self?.updateMonitoredApplications()
        }

        timer = Timer.repeatEvery(kTimerInterval) { [weak self] inTimer in
            self?.updateReviewsForAllApplications()
        }
        
        updateMonitoredApplications();
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
        
        var error: NSError?
        
        if let fetchApplication = ReviewManager.managedObjectContext().existingObjectWithID(objectId, error: &error) as? Application {
            
            if error != nil {
                println(error)
            }
            let itunesService = ItunesService(apId: fetchApplication.trackId, storeId: nil)
            
            itunesService.fetchReviews(itunesService.url) {  [weak self]
                (success: Bool, reviews: [JSON]?, error: NSError?) in
                
                if let reviews = reviews {
                    if reviews.count > 0 {
                        DatabaseHandler.saveReviews(reviews, applactionObjectId: fetchApplication.objectID)
                    }
                }
                
            }
        }
    }
    
    func resetNewReviewsCountForApplication(objectId: NSManagedObjectID) {
        DatabaseHandler.resetNewReviewsCountForApplication(objectId)
    }
}
