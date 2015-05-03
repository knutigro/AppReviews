//
//  ReviewWindowController.swift
//  AppstoreReviews
//
//  Created by Knut Inge Grosland on 2015-04-17.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import AppKit

class ReviewWindowController : NSWindowController {
    
    var managedObjectContext : NSManagedObjectContext!
    
    private var application : Application? {
        didSet {
            if let title = application?.trackName {
                self.window?.title = title
            }
            if let reviewController = self.contentViewController as? ReviewSplitViewController {
                reviewController.application = self.application
            }
        }
    }
    
    var applicationId : NSString? {
        didSet {
            if oldValue != self.applicationId {
                if self.applicationId as? String != nil {
                    self.application = Application.getWithAppId(self.applicationId! as String, context: self.managedObjectContext)
                }
            }
        }
    }

    // MARK: - Init & teardown
    
    class func show(applicationId : NSString) {
        let appdelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        let windowController = appdelegate.reviewsWindowController
        windowController.managedObjectContext = ReviewManager.managedObjectContext()
        windowController.applicationId = applicationId
        windowController.showWindow(self)
        NSApp.activateIgnoringOtherApps(true)
    }

    // MARK: - Loading

    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let reviewController = self.contentViewController as? ReviewSplitViewController {
            reviewController.application = self.application
        }
    }
}

// MARK: - Actions

extension ReviewWindowController {
    
    @IBAction func refreshApplication(sender: AnyObject) {
        if let application = self.application {
            ReviewManager.appUpdater().fetchReviews(application, storeId: nil)
        }
    }
    
    @IBAction func openInAppstore(objects:AnyObject?) {
        let itunesUrl = "http://itunes.apple.com/app/id" + (self.application?.trackId ?? "")
        if let url = NSURL(string: itunesUrl) {
            NSWorkspace.sharedWorkspace().openURL(url)
        }
    }
}
