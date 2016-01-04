//
//  ReviewWindowController.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-04-17.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import AppKit

class ReviewWindowController: NSWindowController {
    var reviewController : ReviewViewController?
    var managedObjectContext: NSManagedObjectContext!
    @IBOutlet weak var automaticUpdate: NSMenuItem?
    @IBOutlet weak var shareButton: NSButton?
    
    var application: Application? {
        didSet {
            if let application = application {
                window?.title = application.trackName
                automaticUpdate?.state = application.settings.automaticUpdate ? NSOnState: NSOffState
                
                if let reviewSplitViewController = contentViewController as? ReviewSplitViewController {
                    reviewSplitViewController.application = application
                }
            }
        }
    }
    
    var objectId: NSManagedObjectID? {
        didSet {
            if oldValue != objectId {
                let context = ReviewManager.managedObjectContext()
                if let objectId = objectId {
                    do {
                        application = try context.existingObjectWithID(objectId) as? Application
                    } catch let error as NSError {
                        print(error)
                    } catch {
                        fatalError()
                    }
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
        
        if let reviewSplitViewController = contentViewController as? ReviewSplitViewController {
            reviewSplitViewController.application = application
            reviewController = reviewSplitViewController.reviewViewController
        }
        
        self.shareButton!.sendActionOn(Int(NSEventMask.LeftMouseDownMask.rawValue))
        
        // Register Keyboard shortcuts.
        NSEvent.addLocalMonitorForEventsMatchingMask(NSEventMaskFromType(.KeyDown), handler: { [weak self]  (event: NSEvent!) -> NSEvent! in
            
            let rChar: UInt16 = 15
            let iChar: UInt16 = 34
            let cChar: UInt16 = 8
            let sChar: UInt16 = 1
            let fChar: UInt16 = 3
            let aChar: UInt16 = 0
            
            if event.modifierFlags.intersect(NSEventModifierFlags.CommandKeyMask) != [] {
                switch event.keyCode {
                case rChar:
                        self?.refreshApplication(nil)
                case aChar:
                        self?.openApplications(nil)
                case iChar:
                        if (event.modifierFlags.intersect(NSEventModifierFlags.ShiftKeyMask) == []) {
                            self?.reviewController?.openInItunesSelectedReview(nil)
                        }
                case cChar:
                        self?.reviewController?.copyToClipBoardSelectedReview(nil)
                case sChar:
                        self?.reviewController?.saveSelectedReview(nil)
                case fChar:
                        self?.reviewController?.shareSelectedReview(nil)
                case 18, 19 , 20, 21, 22, 23, 24, 25:
                    let key = Int(event.keyCode) - 18
                    let appdelegate = NSApplication.sharedApplication().delegate as! AppDelegate
                    let menuItems = appdelegate.statusMenuController.statusItem.menu?.itemArray
                    if menuItems?.count > key {
                        if let menuItem = menuItems?[key], let application = menuItem.representedObject as? Application {
                            ReviewWindowController.show(application.objectID)
                        }
                    }
                default:
                        break
                }
            }

            return event
        })
    }
}

// MARK: - Actions

extension ReviewWindowController {
    
    func openApplications(sender: AnyObject?) {
        let appdelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        let windowController = appdelegate.applicationWindowController
        windowController.showWindow(self)
        NSApp.activateIgnoringOtherApps(true)
    }

    @IBAction func refreshApplication(sender: AnyObject?) {
        if let application = application {
            ReviewManager.appUpdater().fetchReviewsForApplication(application.objectID)
        }
    }

    @IBAction func automaticUpdateDidChangeState(sender: AnyObject) {
        
        guard let menuItem = sender as? NSMenuItem, objectId = application?.objectID else { return  }
        
        let newState = !Bool(menuItem.state)
        menuItem.state = newState ? NSOnState: NSOffState;
        DatabaseHandler.saveDataInContext({ (context) -> Void in
            do {
                if let application = try context.existingObjectWithID(objectId) as? Application {
                    application.settings.automaticUpdate = newState
                }
            } catch let error as NSError {
                print(error)
            } catch {
                fatalError()
            }
        })
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

    @IBAction func sideBarButtonClicked(sender: AnyObject?) {
        guard let reviewSplitViewController = contentViewController as? ReviewSplitViewController else {  return  }
        reviewSplitViewController.toggleLeftMenu()
    }

    @IBAction func exportReviewsClicked(sender: AnyObject?) {
        
        guard let application = application else { return  }
        guard let reviewController = contentViewController as? ReviewSplitViewController else {  return  }
        guard let reviews = reviewController.reviewViewController?.reviewArrayController?.arrangedObjects as? [Review] else {          return   }

        var stringToExport = ""
        for review in reviews {
            stringToExport += "\n\n" + review.toString() + "\n\n_________________________________"
        }
        
        let savePanel = NSSavePanel()
        savePanel.allowedFileTypes = [kUTTypeText as String]
        let result = savePanel.runModal()
        savePanel.title = application.trackName
        savePanel.nameFieldStringValue = application.trackName
        
        if result != NSFileHandlingPanelCancelButton, let url = savePanel.URL {
            do {
                try stringToExport.writeToURL(url, atomically: true, encoding: NSUTF8StringEncoding)
            } catch let error as NSError {
                let alert = NSAlert()
                alert.messageText = (error.localizedDescription)
                alert.beginSheetModalForWindow(window!, completionHandler:nil)
            }
        }
    }
}
