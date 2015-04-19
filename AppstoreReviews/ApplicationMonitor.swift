//
//  ReviewUpdater.swift
//  AppstoreReviews
//
//  Created by Knut Inge Grosland on 2015-04-18.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import AppKit

// Update interval in seconds
let UpdateInterval = 60.0 * 60  // Each Hour

protocol ApplicationMonitorDelegate {
    func applicationMonitor(applicationMonitor : ApplicationMonitor, didUpdateApplications applications: [Application])
    func applicationMonitor(applicationMonitor : ApplicationMonitor, didUpdateReviews reviews: [Review])
}

// MARK: - ApplicationMonitor

extension Application {
    var secondsSinceLastReviewFetch : Int {
        get {
            return Int(NSDate().timeIntervalSinceDate(self.reviewsUpdatedAt))
        }
    }
}


class ApplicationMonitor {
    
    var timer: Timer?
    var applications = [Application]()
    var delegate: ApplicationMonitorDelegate?

    // MARK: - Init & teardown
    
    init() {
        
        self.updateApplications()

        let backgroundManagedObjectContext = DBController.sharedInstance.persistentStack.backgroundManagedObjectContext;

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
                DBController.sharedInstance.appstoreReviewController.fetchReviewsFromItunes(application, storeId: nil)
            }
        }
    }
    
    func updateApplications(){
        if let dBApplications = DBController.sharedInstance.appstoreReviewController.allApplications() {
            for dBApplication in dBApplications {
                
                if !contains(applications, dBApplication) {
                    applications.append(dBApplication)
                    DBController.sharedInstance.appstoreReviewController.fetchReviewsFromItunes(dBApplication, storeId: nil)
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

        self.delegate?.applicationMonitor(self, didUpdateApplications: self.applications)
    }
}
