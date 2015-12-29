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
        
        let _ = NSNotificationCenter.defaultCenter().addObserverForName(kDidUpdateApplicationNotification, object: nil, queue: nil) {  [weak self] notification in
            self?.updateMonitoredApplications()
        }

        let _ = NSNotificationCenter.defaultCenter().addObserverForName(kDidUpdateApplicationSettingsNotification, object: nil, queue: nil) {  [weak self] notification in
            self?.updateMonitoredApplications()
        }

        let _ = NSNotificationCenter.defaultCenter().addObserverForName(kDidUpdateReviewsNotification, object: nil, queue: nil) {  [weak self] notification in
            self?.updateMonitoredApplications()
        }

        timer = Timer.repeatEvery(kTimerInterval) { [weak self] inTimer in
            self?.updateReviewsForAllApplications()
        }
        
        updateMonitoredApplications();
    }
    
    private func updateReviewsForAllApplications() {
        dispatch_async(dispatch_get_main_queue(), { [weak self]  () -> Void in
            guard let strongSelf = self else { return  }
            for application in strongSelf.applications {
                if application.settings.shouldUpdateReviews {
                    strongSelf.fetchReviewsForApplication(application.objectID)
                }
            }
        })
    }
    
    private func updateMonitoredApplications() {
        
        dispatch_async(dispatch_get_main_queue(), { [weak self] () -> Void in
            guard let strongSelf = self else { return  }
            if let dBApplications = DatabaseHandler.allApplications(ReviewManager.managedObjectContext()) {
                for dBApplication in dBApplications {
                    if !strongSelf.applications.contains(dBApplication) {
                        strongSelf.applications.append(dBApplication)
                        strongSelf.fetchReviewsForApplication(dBApplication.objectID)
                    }
                }
                
                var applicationsToRemove = [Application]()
                for application in strongSelf.applications {
                    if !dBApplications.contains(application) {
                        applicationsToRemove.append(application)
                    }
                }
                
                for applicationToRemove in applicationsToRemove {
                    strongSelf.applications.removeObject(applicationToRemove)
                }
            }
        })
        
    }
    
    // MARK: - Reviews handling
    
    func fetchReviewsForApplication(objectId: NSManagedObjectID) {
        do {
            if let fetchApplication = try ReviewManager.managedObjectContext().existingObjectWithID(objectId) as? Application {
                let itunesService = ItunesService(apId: fetchApplication.trackId, storeId: nil)
                itunesService.fetchReviews(itunesService.url) {
                    (reviews: [JSON], error: NSError?) in
                    DatabaseHandler.saveReviews(reviews, applactionObjectId: fetchApplication.objectID)
                }
            }
        } catch let error as NSError {
            print(error)
        } catch {
            fatalError()
        }
    }
    
    func resetNewReviewsCountForApplication(objectId: NSManagedObjectID) {
        DatabaseHandler.resetNewReviewsCountForApplication(objectId)
    }
}
