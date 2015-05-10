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
            if let application = self.application {
                self.window?.title = application.trackName
                self.automaticUpdate?.state = application.settings.automaticUpdate ? NSOnState : NSOffState
                
                if let reviewController = self.contentViewController as? ReviewSplitViewController {
                    reviewController.application = self.application
                }
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
    
    @IBAction func exportReviewsClicked(sender: AnyObject) {
        if let application = self.application {
            
            if let reviewController = self.contentViewController as? ReviewSplitViewController {
                if let reviews = reviewController.reviewViewController?.reviewArrayController?.arrangedObjects as? [Review] {
                  
                    var string = ""
                    
                    for review in reviews {
                        string += "\n\n"
                        string += review.toString()
                        string += "\n\n"
                        string += "_________________________________"
                    }
                    
                    var savePanel = NSSavePanel()
                    savePanel.allowedFileTypes = [kUTTypeText]
                    let result = savePanel.runModal()
                    savePanel.title = application.trackName
                    savePanel.nameFieldStringValue = application.trackName

                    if result != NSFileHandlingPanelCancelButton {
                        if let url = savePanel.URL {
                            var error : NSError?
                            string.writeToURL(url, atomically: true, encoding: NSUTF8StringEncoding, error: &error)
                            
                            if error != nil {
                                var alert = NSAlert()
                                alert.messageText = error?.localizedDescription
                                alert.beginSheetModalForWindow(self.window!, completionHandler:nil)
                            }
                        }
                    }
                }
            }
        }
    }

}
