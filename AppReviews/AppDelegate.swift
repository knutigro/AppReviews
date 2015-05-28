//
//  AppDelegate.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-04-08.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import Cocoa
import AppKit
import SimpleCocoaAnalytics

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    lazy var applicationWindowController: NSWindowController = self.initialApplicationWindowController()
    lazy var aboutWindowController: NSWindowController = self.initialAboutWindowController()
    lazy var reviewsWindowController: ReviewWindowController = self.initialReviewWindowController()
    lazy var launchWindowController: NSWindowController = self.initialLaunchWindowController()

    var statusMenuController: StatusMenuController!
    
    // MARK: Application Process

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        var analyticsHelper = AnalyticsHelper.sharedInstance()
        analyticsHelper.recordScreenWithName("Launch")
        analyticsHelper.beginPeriodicReportingWithAccount("UA-62792522-3", name: "App Reviews OSX", version: NSApplication.v_versionBuild())
        
        // Create ReviewManager shared object
        var manager = ReviewManager.start()
        
        // Create StatusMenu
        statusMenuController = StatusMenuController()

        // Show Launchscreen
        if NSUserDefaults.review_shouldShowLaunchScreen() {
            self.launchWindowController.showWindow(self)
            NSApp.activateIgnoringOtherApps(true)
        }
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
        AnalyticsHelper.sharedInstance().handleApplicationWillClose()
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func applicationShouldTerminate(sender: NSApplication) -> NSApplicationTerminateReply {
        // Saves changes in the application's managed object context before the application terminates.
        ReviewManager.saveContext()
        
        return .TerminateNow
    }
}

// MARK: WindowControllers

extension AppDelegate {
    
    func initialLaunchWindowController() -> NSWindowController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)!
        var windowController = storyboard.instantiateControllerWithIdentifier("LaunchWindowController") as! NSWindowController
        
        return windowController
    }
    
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

