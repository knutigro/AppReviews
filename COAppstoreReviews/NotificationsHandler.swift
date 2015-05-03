//
//  NotificationsHandler.swift
//  AppstoreReviews
//
//  Created by Knut Inge Grosland on 2015-05-02.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import Foundation
import AppKit

@objc
class NotificationsHandler : NSObject {
    
    // MARK: - Init & teardown
    
    override init() {
        super.init()
        
        let applicationSettingsMonitor = NSNotificationCenter.defaultCenter().addObserverForName(kDidAddReviewsNotification, object: nil, queue: nil) {  [weak self] notification in
            if let strongSelf = self {
                if let newReviewsIds = notification.object as? Set<NSManagedObjectID> {
                    
                    var newReviews = [Application : [Review]]()
                    for objectID in newReviewsIds {
                        if let newReview = Review.getWithId(objectID, context: ReviewManager.managedObjectContext()) {
                            if newReviews[newReview.application]?.append(newReview) == nil {
                                var reviewArray = [Review]()
                                reviewArray.append(newReview)
                                newReviews[newReview.application] = reviewArray
                            }
                        }
                    }
                    
                    for application in newReviews.keys {
                        if let reviews = newReviews[application] {
                            strongSelf.newReviewsNotification(application, reviews: reviews)
                        }
                    }
                }
            }
        }
    }
    
    func newReviewsNotification(application: Application, reviews : [Review]) {
        assert(reviews.count > 0, "Reviews should be greater than 0")
        if reviews.count == 0 {  return }
        
        let firstReview = reviews[0]
        
        var totalRating = 0
        for review in reviews {
            totalRating += review.rating.integerValue
        }
        let averageRating = Float(totalRating / reviews.count)

        var title = application.trackName
        var plural =  (reviews.count > 1 ? "s" : "")

        let message = (NSString(format: NSLocalizedString("%@ new review%@. Average: %.1f\n%@", comment: "review.notification.reviewstext"), String(reviews.count), plural, averageRating, firstReview.title)) as String
        
        var notification:NSUserNotification = NSUserNotification()
        notification.title = title
        notification.informativeText = message
        notification.actionButtonTitle = NSLocalizedString("Open Reviews", comment: "review.notification.openReviews")
        notification.hasActionButton = true
        var center : NSUserNotificationCenter = NSUserNotificationCenter.defaultUserNotificationCenter()
        center.delegate = self
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            center.scheduleNotification(notification)
        })
    }
}

extension NotificationsHandler : NSUserNotificationCenterDelegate {
    
    func userNotificationCenter(center: NSUserNotificationCenter, didDeliverNotification notification: NSUserNotification) {
        println("didDeliverNotification")  //this does not print
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        return true
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, didActivateNotification notification: NSUserNotification) {
        println("didActivateNotification \(notification)")  //this does not print
    }
}
