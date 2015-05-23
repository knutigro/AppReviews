//
//  StatusMenu.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-04-16.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import AppKit
import Sparkle

class StatusMenuController: NSObject {
    
    var statusItem: NSStatusItem!
    var applications = [Application]()
    var newReviews = [Int]()
    var applicationArrayController: ApplicationArrayController!
    private var kvoContext = 0
    
    // MARK: - Init & teardown

    deinit {
        removeObserver(self, forKeyPath: "applications", context: &kvoContext)
    }

    override init() {
        super.init()
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1) // NSVariableStatusItemLength
        statusItem.image = NSImage(named: "stausBarIcon")
        statusItem.alternateImage = NSImage(named: "stausBarIcon")
        statusItem.highlightMode = true
        
        applicationArrayController = ApplicationArrayController(content: nil)
        applicationArrayController.managedObjectContext = ReviewManager.managedObjectContext()
        applicationArrayController.entityName = kEntityNameApplication
        var error: NSError? = nil
        var result = applicationArrayController.fetchWithRequest(nil, merge: true, error: &error)
        
        bind("applications", toObject: applicationArrayController, withKeyPath: "arrangedObjects", options: nil)
        
        addObserver(self, forKeyPath: "applications", options: .New, context: &kvoContext)
        
        let applicationMonitor = NSNotificationCenter.defaultCenter().addObserverForName(kDidUpdateApplicationNotification, object: nil, queue: nil) {  [weak self] notification in
        }
        
        let applicationSettingsMonitor = NSNotificationCenter.defaultCenter().addObserverForName(kDidUpdateApplicationSettingsNotification, object: nil, queue: nil) {  [weak self] notification in
            self?.updateMenu()
        }

        updateMenu()
        
        // Initialize Sparkle
        SUUpdater.sharedUpdater()
    }
    
    // MARK: - Handling menu items

    func updateMenu() {
        var menu = NSMenu()

        var newReviews = false

        for application in applications {
            
//            application.addObserver(self, forKeyPath: "settings.newReviews", options: .New, context: &kvoContext)
            var title = application.trackName
            
            if application.settings.newReviews.integerValue > 0 {
                newReviews = true
                title = title + " (" + String(application.settings.newReviews.integerValue) +  ")"
            }

            var menuItem = NSMenuItem(title: title, action: Selector("openReviewsForApp:"), keyEquivalent: "")

            menuItem.representedObject = application
            menuItem.target = self
            menu.addItem(menuItem)
        }
        
        if (applications.count > 0) {
            menu.addItem(NSMenuItem.separatorItem())
        }
        
        var menuItemApplications = NSMenuItem(title: NSLocalizedString("Add / Remove Applications", comment: "statusbar.menu.applications"), action: Selector("openApplications:"), keyEquivalent: "")
        var menuItemAbout = NSMenuItem(title: NSLocalizedString("About Appstore Reviews", comment: "statusbar.menu.about"), action: Selector("openAbout:"), keyEquivalent: "")
        var menuItemQuit = NSMenuItem(title: NSLocalizedString("Quit Appstore Reviews", comment: "statusbar.menu.quit"), action: Selector("quit:"), keyEquivalent: "")

        menuItemApplications.target = self
        menuItemAbout.target = self
        menuItemQuit.target = self

        menu.addItem(menuItemApplications)
        menu.addItem(menuItemAbout)
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(menuItemQuit)
        
        statusItem.menu = menu;
        
        if newReviews {
            statusItem.image = NSImage(named: "stausBarIconHappy")
            statusItem.alternateImage = NSImage(named: "stausBarIconHappy")
        } else {
            statusItem.image = NSImage(named: "stausBarIcon")
            statusItem.alternateImage = NSImage(named: "stausBarIcon")
        }
    }
}

// MARK: - Actions

extension StatusMenuController {
    
    func openReviewsForApp(sender: AnyObject) {
        if let menuItem = sender as? NSMenuItem {
            if let application = menuItem.representedObject as? Application {
                ReviewWindowController.show(application.objectID)
            }
        }
    }
    
    func openAbout(sender: AnyObject) {
        let appdelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        let windowController = appdelegate.aboutWindowController
        windowController.showWindow(self)
        NSApp.activateIgnoringOtherApps(true)
    }
    
    func openApplications(sender: AnyObject) {
        let appdelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        let windowController = appdelegate.applicationWindowController
        windowController.showWindow(self)
        NSApp.activateIgnoringOtherApps(true)
    }
    
    func quit(sender: AnyObject) {
        NSApplication.sharedApplication().terminate(sender)
    }
}

// MARK: - KVO

extension StatusMenuController {
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject: AnyObject], context: UnsafeMutablePointer<Void>) {
        if context == &kvoContext {
//            println("observeValueForKeyPath: " + keyPath +  "change: \(change)" )
//            updateMenu()
        }
        else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }

}