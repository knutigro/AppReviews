//
//  NSApplication+Startup.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-05-29.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

extension NSApplication {
    
    // MARK: Public methods
    
    class func shouldLaunchAtStartup() -> Bool {
        return (itemReferencesInLoginItems().existingReference != nil)
    }
    
    class func toggleShouldLaunchAtStartup() {
        let itemReferences = itemReferencesInLoginItems()
        if (itemReferences.existingReference == nil) {
            NSApplication.addToStartupItems(itemReferences.lastReference)
        } else {
            NSApplication.removeFromStartupItems(itemReferences.existingReference)
        }
    }
    
    class func setShouldLaunchAtStartup(launchAtStartup : Bool) {
        let itemReferences = itemReferencesInLoginItems()
        if (launchAtStartup && itemReferences.existingReference == nil) {
            NSApplication.addToStartupItems(itemReferences.lastReference)
        } else if (!launchAtStartup) {
            NSApplication.removeFromStartupItems(itemReferences.existingReference)
        }
    }
    
    // MARK: Private methods

    private class func itemReferencesInLoginItems() -> (existingReference: LSSharedFileListItemRef?, lastReference: LSSharedFileListItemRef?) {
        
        let itemUrl : UnsafeMutablePointer<Unmanaged<CFURL>?> = UnsafeMutablePointer<Unmanaged<CFURL>?>.alloc(1)
        if let appUrl : NSURL = NSURL.fileURLWithPath(NSBundle.mainBundle().bundlePath) {
            let loginItemsRef = LSSharedFileListCreate(
                nil,
                kLSSharedFileListSessionLoginItems.takeRetainedValue(),
                nil
                ).takeRetainedValue() as LSSharedFileListRef?
            if loginItemsRef != nil {
                let loginItems: NSArray = LSSharedFileListCopySnapshot(loginItemsRef, nil).takeRetainedValue() as NSArray
                let lastItemRef: LSSharedFileListItemRef? = (loginItems.lastObject as! LSSharedFileListItemRef)
                for var i = 0; i < loginItems.count; ++i {
                    
                    let currentItemRef: LSSharedFileListItemRef = loginItems.objectAtIndex(i) as! LSSharedFileListItemRef
                    //                    let url = LSSharedFileListItemCopyResolvedURL(currentItemRef, 0, nil).takeRetainedValue()
                    
                    if LSSharedFileListItemResolve(currentItemRef, 0, itemUrl, nil) == noErr {
                        if let urlRef: NSURL =  itemUrl.memory?.takeRetainedValue() {
                            if urlRef.isEqual(appUrl) {
                                return (currentItemRef, lastItemRef)
                            }
                        }
                    } else {
                        print("Unknown login application")
                    }
                }
                //The application was not found in the startup list
                return (nil, lastItemRef)
            }
        }

        return (nil, nil)
    }
    
    private class func removeFromStartupItems(existingReference: LSSharedFileListItemRef?) {
        if let existingReference = existingReference,
            let loginItemsRef = LSSharedFileListCreate(nil, kLSSharedFileListSessionLoginItems.takeRetainedValue(), nil).takeRetainedValue() as LSSharedFileListRef? {
            LSSharedFileListItemRemove(loginItemsRef, existingReference);
        }
    }
    
    private class func addToStartupItems(lastReference: LSSharedFileListItemRef?) {
        if let lastReference = lastReference,
            let loginItemsRef = LSSharedFileListCreate(nil, kLSSharedFileListSessionLoginItems.takeRetainedValue(), nil).takeRetainedValue() as LSSharedFileListRef? {
            if let appUrl : CFURLRef = NSURL.fileURLWithPath(NSBundle.mainBundle().bundlePath) {
                LSSharedFileListInsertItemURL(loginItemsRef, lastReference, nil, nil, appUrl, nil, nil)
            }
        }
    }
}