//
//  StatusMenu.swift
//  AppstoreReviews
//
//  Created by Knut Inge Grosland on 2015-04-16.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import AppKit

class StatusMenuApplicationItem {
    var applicationName : String
    var applicationId : String
    var numberOfNewReviews = 0
    
    init(applicationName : String, applicationId : String) {
        self.applicationName = applicationName
        self.applicationId = applicationId
    }
}

class StatusMenuController : NSObject {
    
    var statusItem: NSStatusItem!
    var applicationItems = [StatusMenuApplicationItem]()

    // MARK: - Init & teardown

    override init() {
        super.init()
        self.statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1) // NSVariableStatusItemLength
        self.statusItem.image = NSImage(named: "star-highlighted")
        self.statusItem.alternateImage = NSImage(named: "star")
        self.statusItem.highlightMode = true
        
        self.updateApplicationItems()
        
        let backgroundManagedObjectContext = DBController.sharedInstance.persistentStack.backgroundManagedObjectContext;
        
        let newToken = NSNotificationCenter.defaultCenter().addObserverForName(NSManagedObjectContextDidSaveNotification, object: nil, queue: nil) { notification in
            if notification.object as? NSManagedObjectContext == backgroundManagedObjectContext {
                
                if let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as? NSSet {
                    for object in insertedObjects {
                        if let application = object as? Application {
                            self.updateApplicationItems()
                            return
                        }
                    }
                }
                if let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] as? NSSet {
                    for object in deletedObjects {
                        if let application = object as? Application {
                            self.updateApplicationItems()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Handling menu items

    func updateMenu() {
        var menu = NSMenu()
        
        for application in applicationItems {
            var menuItem = NSMenuItem(title: application.applicationName, action: Selector("openReviewsForApp:"), keyEquivalent: "")
            menuItem.representedObject = application
            menuItem.target = self
            menu.addItem(menuItem)
        }
        
        if (applicationItems.count > 0) {
            menu.addItem(NSMenuItem.separatorItem())
        }
        
        var menuItemAbout = NSMenuItem(title: NSLocalizedString("About Appstore Review", comment: "statusbar.menu.about"), action: Selector("openAbout:"), keyEquivalent: "")
        menuItemAbout.target = self
        var menuItemPreferences = NSMenuItem(title: NSLocalizedString("Preferences", comment: "statusbar.menu.settings"), action: Selector("openSettings:"), keyEquivalent: "")
        menuItemPreferences.target = self
        var menuItemQuit = NSMenuItem(title: NSLocalizedString("Quit Appstore Review", comment: "statusbar.menu.quit"), action: Selector("quit:"), keyEquivalent: "")
        menuItemQuit.target = self

        menu.addItem(menuItemAbout)
        menu.addItem(menuItemPreferences)
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(menuItemQuit)
        
        self.statusItem.menu = menu;
    }
    
    func updateApplicationItems(){
        if let applications = DBController.sharedInstance.reviewController.fetchAllApplications() {
            self.applicationItems.removeAll(keepCapacity: false)
            for application in applications {
                if !application.trackName.isEmpty && !application.trackId.isEmpty  {
                    self.applicationItems.append(StatusMenuApplicationItem(applicationName: application.trackName, applicationId: application.trackId))
                }
            }
        }
        self.updateMenu()
    }
}

// MARK: - Actions

extension StatusMenuController {
    
    func openReviewsForApp(sender : AnyObject) {
        if let menuItem = sender as? NSMenuItem {
            if let application = menuItem.representedObject as? StatusMenuApplicationItem {
                ReviewWindowController.show(application.applicationId)
            }
        }
    }
    
    func openAbout(sender : AnyObject) {
        
    }
    
    func openSettings(sender : AnyObject) {
        let appdelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        let windowController = appdelegate.settingsWindowController
        windowController.showWindow(self)
        NSApp.activateIgnoringOtherApps(true)
    }
    
    func quit(sender : AnyObject) {
        NSApplication.sharedApplication().terminate(sender)
    }
}