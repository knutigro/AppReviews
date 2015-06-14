//
//  StatusMenu.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-04-16.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import AppKit

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
    }
    
    // MARK: - Handling menu items

    func updateMenu() {
        var menu = NSMenu()

        var newReviews = false

        var idx = 1
        for application in applications {
            
//            application.addObserver(self, forKeyPath: "settings.newReviews", options: .New, context: &kvoContext)
            var title = application.trackName
            
            if application.settings.newReviews.integerValue > 0 {
                newReviews = true
                title = title + " (" + String(application.settings.newReviews.integerValue) +  ")"
            }
            
            let shortKey = idx < 10 ? String(idx) : ""
            var menuItem = NSMenuItem(title: title, action: Selector("openReviewsForApp:"), keyEquivalent: shortKey)

            menuItem.representedObject = application
            menuItem.target = self
            menu.addItem(menuItem)
            idx++
        }
        
        if (applications.count > 0) {
            menu.addItem(NSMenuItem.separatorItem())
        }
        
        var menuItemApplications = NSMenuItem(title: NSLocalizedString("Add / Remove Applications", comment: "statusbar.menu.applications"), action: Selector("openApplications:"), keyEquivalent: "a")
        var menuItemAbout = NSMenuItem(title: NSLocalizedString("About Appstore Reviews", comment: "statusbar.menu.about"), action: Selector("openAbout:"), keyEquivalent: "")
        var menuItemProvidFeedback = NSMenuItem(title: NSLocalizedString("Provide Feedback...", comment: "statusbar.menu.feedback"), action: Selector("openFeedback:"), keyEquivalent: "")

        var menuItemQuit = NSMenuItem(title: NSLocalizedString("Quit", comment: "statusbar.menu.quit"), action: Selector("quit:"), keyEquivalent: "q")
        
        var menuItemLaunchAtStartup = NSMenuItem(title: NSLocalizedString("Launch at startup", comment: "statusbar.menu.startup"), action: Selector("launchAtStartUpToggle:"), keyEquivalent: "")
        menuItemLaunchAtStartup.state = NSApplication.shouldLaunchAtStartup() ? NSOnState : NSOffState

        menuItemApplications.target = self
        menuItemAbout.target = self
        menuItemQuit.target = self
        menuItemProvidFeedback.target = self
        menuItemLaunchAtStartup.target = self

        menu.addItem(menuItemApplications)
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(menuItemLaunchAtStartup)
        menu.addItem(menuItemProvidFeedback)
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(menuItemAbout)
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
    
    func openReviewsForApp(sender: AnyObject?) {
        if let menuItem = sender as? NSMenuItem {
            if let application = menuItem.representedObject as? Application {
                ReviewWindowController.show(application.objectID)
            }
        }
    }
    
    func openAbout(sender: AnyObject?) {
        let appdelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        let windowController = appdelegate.aboutWindowController
        windowController.showWindow(self)
        NSApp.activateIgnoringOtherApps(true)
    }
    
    func openApplications(sender: AnyObject?) {
        let appdelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        let windowController = appdelegate.applicationWindowController
        windowController.showWindow(self)
        NSApp.activateIgnoringOtherApps(true)
    }
    
    func openFeedback(sender: AnyObject?) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "http://knutigro.github.io/apps/app-reviews/#Feedback")!)
    }
    
    func launchAtStartUpToggle(sender : AnyObject?) {
        if let menu =  sender as? NSMenuItem {
            NSApplication.toggleShouldLaunchAtStartup()
            menu.state = NSApplication.shouldLaunchAtStartup() ? NSOnState : NSOffState
        }
    }
    
    func quit(sender: AnyObject?) {
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