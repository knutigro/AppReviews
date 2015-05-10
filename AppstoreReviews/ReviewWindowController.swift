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
    @IBOutlet weak var automaticUpdate: NSMenuItem?
    
    var application : Application? {
        didSet {
            if let title = application?.trackName {
                self.window?.title = title
            }
            if let reviewController = self.contentViewController as? ReviewSplitViewController {
                reviewController.application = self.application
            }
            if let automaticUpdate = application?.settings.automaticUpdate {
                self.automaticUpdate?.state = automaticUpdate ? NSOnState : NSOffState
            }
        }
    }
    
    var objectId : NSManagedObjectID? {
        didSet {
            if oldValue != self.objectId {
                var context = ReviewManager.managedObjectContext()
                var error : NSError?
                if let objectId = objectId {
                    self.application = context.existingObjectWithID(objectId, error: &error) as? Application
                }
            }
        }
    }

    // MARK: - Init & teardown
    
    class func show(objectId : NSManagedObjectID) {
        let appdelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        let windowController = appdelegate.reviewsWindowController
        windowController.managedObjectContext = ReviewManager.managedObjectContext()
        windowController.objectId = objectId
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
            ReviewManager.appUpdater().fetchReviewsForApplication(application.objectID)
        }
    }

    @IBAction func automaticUpdateDidChangeState(sender: AnyObject) {
        if let menuItem = sender as? NSMenuItem, objectId = self.application?.objectID {
            let newState = !Bool(menuItem.state)
            menuItem.state = newState ? NSOnState : NSOffState;
            DatabaseHandler.saveDataInContext({ (context) -> Void in
                var error : NSError?
                if let application = context.existingObjectWithID(objectId, error: &error) as? Application {
                    application.settings.automaticUpdate = newState
                }
            })
        }
    }

    @IBAction func openInAppstore(objects:AnyObject?) {
        let itunesUrl = "http://itunes.apple.com/app/id" + (self.application?.trackId ?? "")
        if let url = NSURL(string: itunesUrl) {
            NSWorkspace.sharedWorkspace().openURL(url)
        }
    }
}
