//
//  AppDelegate.swift
//  AppstoreReviews
//
//  Created by Knut Inge Grosland on 2015-04-08.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import Cocoa
import AppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    lazy var applicationWindowController: NSWindowController = self.initialApplicationWindowController()
    lazy var aboutWindowController: NSWindowController = self.initialAboutWindowController()
    lazy var reviewsWindowController: ReviewWindowController = self.initialReviewWindowController()

    var statusMenuController: StatusMenuController!
    
    // MARK : Application Process

    func applicationDidFinishLaunching(aNotification: NSNotification) {

        // Create ReviewManager shared object
        var manager = ReviewManager.start()
        
        // Create StatusMenu
        self.statusMenuController = StatusMenuController()
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminate(sender: NSApplication) -> NSApplicationTerminateReply {
        // Saves changes in the application's managed object context before the application terminates.
        ReviewManager.saveContext()
        
        return .TerminateNow
    }
}

// MARK : WindowControllers

extension AppDelegate {
    
    func initialApplicationWindowController() -> NSWindowController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)!
        var windowController = storyboard.instantiateControllerWithIdentifier("ApplicationWindowController") as! NSWindowController
        
        return windowController
    }
    
    func initialReviewWindowController() -> ReviewWindowController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)!
        var windowController = storyboard.instantiateControllerWithIdentifier("ReviewWindowsController") as! ReviewWindowController
        
        return windowController
    }
    
    func initialAboutWindowController() -> NSWindowController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)!
        var windowController = storyboard.instantiateControllerWithIdentifier("AboutWindowController") as! NSWindowController
        
        return windowController
    }
}

