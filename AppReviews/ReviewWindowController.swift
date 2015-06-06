//
//  ReviewWindowController.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-04-17.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import AppKit

class ReviewWindowController: NSWindowController {
    
    var managedObjectContext: NSManagedObjectContext!
    @IBOutlet weak var automaticUpdate: NSMenuItem?
    @IBOutlet weak var shareButton: NSButton?
    
    var application: Application? {
        didSet {
            if let application = application {
                window?.title = application.trackName
                automaticUpdate?.state = application.settings.automaticUpdate ? NSOnState: NSOffState
                
                if let reviewController = contentViewController as? ReviewSplitViewController {
                    reviewController.application = application
                }
            } 
        }
    }
    
    var objectId: NSManagedObjectID? {
        didSet {
            if oldValue != objectId {
                var context = ReviewManager.managedObjectContext()
                var error: NSError?
                if let objectId = objectId {
                    application = context.existingObjectWithID(objectId, error: &error) as? Application
                }
            }
        }
    }

    // MARK: - Init & teardown
    
    class func show(objectId: NSManagedObjectID) {
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
        
        // Update frame manually
        let frame = self.window!.frame
        self.window?.setFrame(NSRect(x: frame.origin.x, y: frame.origin.y, width: 800, height: 700), display: true)
        
        if let reviewController = contentViewController as? ReviewSplitViewController {
            reviewController.application = application
        }
        
        self.shareButton!.sendActionOn(Int(NSEventMask.LeftMouseDownMask.rawValue))
    }
}

// MARK: - Actions

extension ReviewWindowController {
    
    @IBAction func refreshApplication(sender: AnyObject) {
        if let application = application {
            ReviewManager.appUpdater().fetchReviewsForApplication(application.objectID)
        }
    }

    @IBAction func automaticUpdateDidChangeState(sender: AnyObject) {
        if let menuItem = sender as? NSMenuItem, objectId = application?.objectID {
            let newState = !Bool(menuItem.state)
            menuItem.state = newState ? NSOnState: NSOffState;
            DatabaseHandler.saveDataInContext({ (context) -> Void in
                var error: NSError?
                if let application = context.existingObjectWithID(objectId, error: &error) as? Application {
                    application.settings.automaticUpdate = newState
                }
            })
        }
    }

    @IBAction func openInAppstore(objects: AnyObject?) {
        let itunesUrl = "http://itunes.apple.com/app/id" + (application?.trackId ?? "")
        if let url = NSURL(string: itunesUrl) {
            NSWorkspace.sharedWorkspace().openURL(url)
        }
    }
    
    @IBAction func shareButtonClicked(sender: AnyObject?) {
        if let reviewSplitController = contentViewController as? ReviewSplitViewController {
            reviewSplitController.reviewViewController?.shareSelectedReview(sender)
        }
    }
    
    @IBAction func exportReviewsClicked(sender: AnyObject) {
        if let application = application {
            
            if let reviewController = contentViewController as? ReviewSplitViewController {
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
                            var error: NSError?
                            string.writeToURL(url, atomically: true, encoding: NSUTF8StringEncoding, error: &error)
                            
                            if error != nil {
                                var alert = NSAlert()
                                alert.messageText = error?.localizedDescription
                                alert.beginSheetModalForWindow(window!, completionHandler:nil)
                            }
                        }
                    }
                }
            }
        }
    }
}
