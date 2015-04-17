//
//  ReviewWindowController.swift
//  AppstoreReviews
//
//  Created by Knut Inge Grosland on 2015-04-17.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import AppKit

class ReviewWindowController : NSWindowController {
    
    class func show(applicationId : NSString) {
        
        let appdelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        let windowController = appdelegate.reviewsWindowController
        if let reviewController = windowController.contentViewController as? ReviewViewController {
            reviewController.applicationId = applicationId
        }
        windowController.showWindow(self)
        NSApp.activateIgnoringOtherApps(true)
    }
}
