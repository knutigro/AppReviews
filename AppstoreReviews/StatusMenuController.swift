//
//  StatusMenu.swift
//  AppstoreReviews
//
//  Created by Knut Inge Grosland on 2015-04-16.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import AppKit

class StatusMenuController : NSObject {
    
    var statusItem: NSStatusItem!
    var applications = [Application]()
    var newReviews = [Int]()
    var applicationArrayController : ApplicationArrayController!
    private var kvoContext = 0
    
    // MARK: - Init & teardown

    deinit {
        self.removeObserver(self, forKeyPath: "applications", context: &kvoContext)
    }

    override init() {
        super.init()
        self.statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1) // NSVariableStatusItemLength
        self.statusItem.image = NSImage(named: "stausBarIcon")
        self.statusItem.alternateImage = NSImage(named: "stausBarIcon")
        self.statusItem.highlightMode = true
        
        self.applicationArrayController = ApplicationArrayController(content: nil)
        self.applicationArrayController.managedObjectContext = ReviewManager.managedObjectContext()
        self.applicationArrayController.entityName = kEntityNameApplication
        var error : NSError? = nil
        var result = self.applicationArrayController.fetchWithRequest(nil, merge: true, error: &error)
        
        self.bind("applications", toObject: self.applicationArrayController, withKeyPath: "arrangedObjects", options: nil)
        
        self.addObserver(self, forKeyPath: "applications", options: .New, context: &kvoContext)
        
        let applicationMonitor = NSNotificationCenter.defaultCenter().addObserverForName(kDidUpdateApplicationNotification, object: nil, queue: nil) {  [weak self] notification in
            if let strongSelf = self {
                strongSelf.updateMenu()
            }
        }
        
        let applicationSettingsMonitor = NSNotificationCenter.defaultCenter().addObserverForName(kDidUpdateApplicationSettingsNotification, object: nil, queue: nil) {  [weak self] notification in
            if let strongSelf = self {
                strongSelf.updateMenu()
            }
        }

        self.updateMenu()
    }
    
    // MARK: - Handling menu items

    func updateMenu() {
        var menu = NSMenu()

        var newReviews = false

        for application in self.applications {
            
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
        
        var menuItemApplications = NSMenuItem(title: NSLocalizedString("Add / Remove Apps", comment: "statusbar.menu.applications"), action: Selector("openApplications:"), keyEquivalent: "")
        var menuItemAbout = NSMenuItem(title: NSLocalizedString("About App Reviews", comment: "statusbar.menu.about"), action: Selector("openAbout:"), keyEquivalent: "")
        var menuItemQuit = NSMenuItem(title: NSLocalizedString("Quit App Reviews", comment: "statusbar.menu.quit"), action: Selector("quit:"), keyEquivalent: "")

        menuItemApplications.target = self
        menuItemAbout.target = self
        menuItemQuit.target = self

        menu.addItem(menuItemApplications)
        menu.addItem(menuItemAbout)
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(menuItemQuit)
        
        self.statusItem.menu = menu;
        
        if newReviews {
            self.statusItem.image = NSImage(named: "stausBarIconHappy")
            self.statusItem.alternateImage = NSImage(named: "stausBarIconHappy")
        } else {
            self.statusItem.image = NSImage(named: "stausBarIcon")
            self.statusItem.alternateImage = NSImage(named: "stausBarIcon")
        }
    }
}

// MARK: - Actions

extension StatusMenuController {
    
    func openReviewsForApp(sender : AnyObject) {
        if let menuItem = sender as? NSMenuItem {
            if let application = menuItem.representedObject as? Application {
                ReviewWindowController.show(application.trackId)
            }
        }
    }
    
    func openAbout(sender : AnyObject) {
        let appdelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        let windowController = appdelegate.aboutWindowController
        windowController.showWindow(self)
        NSApp.activateIgnoringOtherApps(true)
    }
    
    func openApplications(sender : AnyObject) {
        let appdelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        let windowController = appdelegate.applicationWindowController
        windowController.showWindow(self)
        NSApp.activateIgnoringOtherApps(true)
    }
    
    func quit(sender : AnyObject) {
        NSApplication.sharedApplication().terminate(sender)
    }
}

// MARK: - KVO

extension StatusMenuController {
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if context == &kvoContext {
//            println("observeValueForKeyPath: " + keyPath +  "change: \(change)" )
//            self.updateMenu()
        }
        else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }

}